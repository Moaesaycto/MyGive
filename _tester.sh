#!/bin/dash

# ============================================================
#                 ASSIGNMENT 1 CUSTOM CHECKER
# ============================================================
# READ ME
# To run this file, provide a list of tests and a test number.
# It will run the outputs consecutively for both the reference
# implementation and the one I've made.
#
# It will store all the results in /test_results/test#, where
# you can use the diff command to manually check for any
# issues surrounding the outputs.
#
# Also the tests that were very generously given to us were
# found in a directory called provided_tests (in case that
# wasn't obvious).
#
# A bit janky, but it's good enough.

if [ $# -ne 2 ]; then
    echo "Usage: $0 <test_number> <tests_string> (received $# arguments)"
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

test_num="$1"
tests="$2"
outdir="test_results/test$test_num"

rm -rf ".mygive" "$outdir"
mkdir -p "$outdir"
mkdir ".mygive"            # TESTED SEPARATELY
mkdir ".mygive/.reference" # TESTED SEPARATELY

status_log="$outdir/status_diff"
: >"$status_log"

i=1
echo "$tests" | while IFS= read -r line; do
    [ -z "$line" ] && continue

    # Folder for this individual test (a bit annoying to read but good to keep track)
    test_dir="$outdir/cmd$i"
    mkdir -p "$test_dir"

    exp_stdout="$test_dir/exp_stdout"
    exp_stderr="$test_dir/exp_stderr"
    exp_status="$test_dir/exp_status"
    cap_stdout="$test_dir/cap_stdout"
    cap_stderr="$test_dir/cap_stderr"
    cap_status="$test_dir/cap_status"

    # Running the actual commands
    eval "FAKETIME=\"1999-12-05 20:41:48\" 2041 $line" >"$exp_stdout" 2>"$exp_stderr"
    echo $? >"$exp_status"
    eval "FAKETIME=\"1999-12-05 20:41:48\" ./$line" >"$cap_stdout" 2>"$cap_stderr"
    echo $? >"$cap_status"

    fail=0
    if ! cmp -s "$exp_stdout" "$cap_stdout"; then
        echo "Test $i stdout mismatch: '$line'" >>"$status_log"
        fail=1
    fi

    if ! cmp -s "$exp_stderr" "$cap_stderr"; then
        echo "Test $i stderr mismatch: '$line'" >>"$status_log"
        fail=1
    fi

    if ! cmp -s "$exp_status" "$cap_status"; then
        echo "Test $i exit_status mismatch: '$line'" >>"$status_log"
        fail=1
    fi

    if [ "$fail" -eq 0 ]; then
        echo -n "${GREEN}$i ${RESET}"
    else
        echo -n "${RED}$i ${RESET}"
    fi

    i=$((i + 1))
done

echo "\n"

if [ -s "$status_log" ]; then
    echo "--- Failures ---"
    echo -n "${RED}"
    cat "$status_log"
    echo -n "${RESET}"
else
    echo "${GREEN}All tests passed!${RESET}"
fi
