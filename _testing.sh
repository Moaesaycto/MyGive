#!/bin/dash

# README
#   The main logic for testing (mygive-test and mygive-mark) is in
#   this file.
#
#

# Running a test for a given/expected stream outputs (provided options and exit code)
run_test() {
    local testname="$1"
    local stdout_out="$2"
    local stdout_exp="$3"
    local stderr_out="$4"
    local stderr_exp="$5"
    local options="$6"
    local exit_out="$7"
    local exit_expect="$8"
    local marking="${9:-0}" # 1 for marks (default 0)

    local has_b=0 has_c=0 has_d=0 has_w=0
    echo "$options" | grep -q 'b' && has_b=1
    echo "$options" | grep -q 'c' && has_c=1
    echo "$options" | grep -q 'd' && has_d=1
    echo "$options" | grep -q 'w' && has_w=1

    # Applies filtering options (order matters)
    apply_options() {
        if [ "$has_c" -eq 1 ]; then tr '[:upper:]' '[:lower:]'; else cat; fi |
            if [ "$has_d" -eq 1 ]; then tr -cd '0-9\n'; else cat; fi |
            if [ "$has_w" -eq 1 ]; then tr -d ' \t'; else cat; fi |
            if [ "$has_b" -eq 1 ]; then grep -v '^$'; else cat; fi
    }

    # Checks if adding a newline makes files identical
    # Patchy but it seems to work
    check_newline_fix() {
        local base="$1"
        local target="$2"
        local tmp_cmp
        tmp_cmp=$(mktemp)

        cat "$base" >"$tmp_cmp"
        echo "" >>"$tmp_cmp"
        cmp -s "$tmp_cmp" "$target"
        local result=$?

        rm -f "$tmp_cmp"
        return "$result"
    }

    local log
    log=$(mktemp)
    local failed=0

    # Function to test a single stream at a time
    # Everything is checked via file and not by string
    # This is the main part of the actual testing logic
    check_stream() {
        local stream="$1"
        local output="$2"   # path not raw file contents
        local expected="$3" # ditto

        # NOTE: avoid local on the same line, it throws a fit
        local tmp_out tmp_exp
        tmp_out=$(mktemp)
        tmp_exp=$(mktemp)

        apply_options <"$output" >"$tmp_out"
        apply_options <"$expected" >"$tmp_exp"

        local output_size expected_size filtered_output_size filtered_expected_size
        output_size=$(stat -c %s "$output")
        expected_size=$(stat -c %s "$expected")
        filtered_output_size=$(stat -c %s "$tmp_out")
        filtered_expected_size=$(stat -c %s "$tmp_exp")

        size_diff=$((filtered_output_size - filtered_expected_size))

        # Read the error messages to understand what each condition catches
        if [ "$expected_size" -eq 0 ] && [ "$filtered_output_size" -gt 1 ]; then
            failed=1
            {
                echo "--- No $stream expected, these $output_size bytes produced:"
                cat "$output"
                echo ""
            } >>"$log"
        elif [ "$output_size" -eq 0 ] && [ "$filtered_expected_size" -gt 1 ]; then
            failed=1
            {
                echo "--- No $stream produced, these $expected_size bytes expected:"
                cat "$expected"
                echo ""
            } >>"$log"
        elif ! diff "$tmp_out" "$tmp_exp" >/dev/null; then
            if [ "$has_b" -ne 1 ] && [ "$size_diff" -eq 1 ] && check_newline_fix "$tmp_exp" "$tmp_out"; then
                failed=1
                echo "Extra newline at end of $stream" >>"$log"
            elif [ "$has_b" -ne 1 ] && [ "$size_diff" -eq -1 ] && check_newline_fix "$tmp_out" "$tmp_exp"; then
                failed=1
                echo "Missing newline at end of $stream" >>"$log"
            elif is_logically_empty "$tmp_out" && is_logically_empty "$tmp_exp"; then
                : # Do nothing
            elif [ "$filtered_output_size" -eq "$filtered_expected_size" ] && [ "$filtered_output_size" -eq 0 ]; then
                : # Also do nothing
            else
                failed=1
                {
                    echo "--- Incorrect $stream of $output_size bytes:"
                    cat "$output"
                    echo ""
                    echo "--- Correct $stream is these $expected_size bytes:"
                    cat "$expected"
                    echo ""
                } >>"$log"
            fi
        fi

        rm -f "$tmp_out" "$tmp_exp"
    }

    # Check both stdout and stderr
    check_stream "stdout" "$stdout_out" "$stdout_exp"
    check_stream "stderr" "$stderr_out" "$stderr_exp"

    # Check exit status
    if [ "$exit_out" -ne "$exit_expect" ]; then
        echo "Exit status of $exit_out incorrect should be $exit_expect" >>"$log"
        failed=1
    fi

    if [ "$failed" -eq 0 ]; then
        if [ "$marking" -eq 1 ]; then
            marks_file="$(dirname "$stdout_exp")/marks"
            if [ -f "$marks_file" ]; then
                marks=$(cat "$marks_file")
                echo "* Test $testname passed ($marks marks)."
            else
                echo "* Test $testname passed (marks not found)."
            fi
        else
            echo "* Test $testname passed."
        fi
    else
        echo "* Test $testname failed."
        cat "$log"
    fi

    rm -f "$log"
    return "$failed"
}

# Call this function to activate the sequence of testing and marking. This is the one
# called in the main files
testing() {
    local assignment="$1"
    local filename="$2"
    local marking="$3"

    tmpdir=$(mktemp -d)

    # Assuming it is safe (checked when mygive-add ran)
    tar -xf "$root/$assignment/_TESTS" -C "$tmpdir" 2>/dev/null # /dev/null for time stamp issues

    passed=0
    failed=0
    total_marks=0
    earned_marks=0
    for testdir in "$tmpdir"/*; do
        testname=$(basename "$testdir")

        # Skipping marks
        if [ "$marking" -eq 1 ] && [ ! -f "$testdir/marks" ]; then
            continue
        fi

        if [ "$marking" -ne 1 ] && [ -f "$testdir/marks" ]; then
            continue
        fi

        # Read marks value if marking is enabled
        test_marks=0
        if [ "$marking" -eq 1 ] && [ -f "$testdir/marks" ]; then
            test_marks=$(cat "$testdir/marks")
            total_marks=$((total_marks + test_marks))
        fi

        args=$(cat "$testdir/arguments" 2>/dev/null || echo "") # Nothing fancy for getting args

        stdin_file="$testdir/stdin"

        # May want to change this, using /dev/null to be safe
        if [ ! -f "$stdin_file" ]; then
            stdin_file="/dev/null"
        fi

        # File checking handled externally
        exp_stdout_file=$(ensure_file_or_temp "$testdir/stdout")
        exp_stderr_file=$(ensure_file_or_temp "$testdir/stderr")

        expected_status=$(cat "$testdir/exit_status" 2>/dev/null || echo "0")
        options=$(cat "$testdir/options" 2>/dev/null || echo "")

        actual_stdout=$(mktemp)
        actual_stderr=$(mktemp)

        # /dev/null shenanigans (which stores as null)
        if [ ! -x "$filename" ]; then
            : >"$actual_stdout"
            : >"$actual_stderr"
            exit_code=0
        else
            eval "./$filename" "$args" <"$stdin_file" >"$actual_stdout" 2>"$actual_stderr"
            exit_code=$?
        fi

        # Fat line (hope that's not a style issue)
        if run_test "$testname" "$actual_stdout" "$exp_stdout_file" "$actual_stderr" \
            "$exp_stderr_file" "$options" "$exit_code" "$expected_status" "$marking"; then
            passed=$((passed + 1))
            if [ "$marking" -eq 1 ]; then
                earned_marks=$((earned_marks + test_marks))
            fi
        else
            failed=$((failed + 1))
        fi

        rm -f "$actual_stdout" "$actual_stderr"
    done

    if [ "$marking" -eq 1 ]; then
        echo "** $passed tests passed, $failed tests failed - mark: $earned_marks/$total_marks"
    else
        echo "** $passed tests passed, $failed tests failed"
    fi

}
