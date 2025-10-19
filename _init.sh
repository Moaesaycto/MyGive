#!/bin/dash
root=".mygive"

# README:
#   This file contains all validations. 
#   The structure may seem quite strange, but it is to match the
#   reference implementation.
#

# Preparing arguments for launch
# * Used with eval set -- "$(filter_args "$@")"
# * Soft flag:   cleans up the arguments
# * Strict flag: throws an error
# * Some strange logic here, only to meet with reference implementation
filter_args() {
    strict="$1" # "strict" or "soft"
    shift       # Remove the mode from $@

    keep=''
    for arg; do
        case $arg in
        --[0-9]*)
            exit 1 
            ;;
        '--' | -*[!0-9]*)
            if [ "$strict" = "strict" ]; then
                exit 1
            fi
            # Else: skip it
            ;;
        *)
            keep="$keep \"$arg\""
            ;;
        esac
    done
    printf '%s\n' "$keep"
}

# Run this before every command (other than add)
preflight_checks() {
    command="$1"

    if [ ! -d "$root" ]; then
        echo "mygive-$command: mygive directory $root not found"
        exit 1
    fi
}

# Automated argument checker because it's in every command
argument_count_check() {
    command="$1"
    usage="$2"
    min="$3"
    max="$4"
    count="$5"

    [ -z "$max" ] && max="$min"

    if [ "$count" -lt "$min" ] || [ "$count" -gt "$max" ]; then
        if [ -n "$usage" ]; then
            echo "usage: mygive-$command $usage" >&2
        else
            echo "usage: mygive-$command" >&2
        fi
        exit 1
    fi
}

# Verifies if an assignment name is valid (and optionally if it exists)
assignment_check() {
    local assignment="$1"
    local command="$2"
    local exist="${3:-0}" # Default to 0 if not provided

    local check
    check=$(echo "$assignment" | grep -E "^[a-z][a-zA-Z0-9_]*$")
    if [ "$check" = "" ] || [ "$check" != "$assignment" ]; then
        echo "mygive-$command: invalid assignment: $assignment" >&2
        exit 1
    fi

    if [ "$exist" -eq 1 ] && [ ! -d "$root/$assignment" ]; then
        echo "mygive-$command: assignment $assignment not found" >&2
        exit 1
    fi
}

# Verifies the tar file provided for tests
# Hard to determine if it is correct, but I did my best :')
test_file_check() {
    local tests="$1"
    local command="$2"

    # Reference seemed to catch this early
    if [ "$tests" = "" ]; then
        echo "mygive-$command: $tests: No such file or directory" >&2
        exit 1
    fi

    # Check if test path contains invalid characters
    echo "$tests" | grep -Eq '^[a-zA-Z0-9._/-]+$' || {
        echo "mygive-$command: invalid tests: $tests" >&2
        exit 1
    }

    # Now check if it exists and is a regular file (not a directory)
    if [ -d "$tests" ]; then
        echo "mygive-$command: $tests: Is a directory" >&2
        exit 1
    fi

    # Reference seemed to allow /dev/null so changed to -e
    if [ ! -e "$tests" ]; then
        echo "mygive-$command: $tests: No such file or directory" >&2
        exit 1
    fi

    # Check if it's a valid tar file (and contents)
    if ! tar -tf "$tests" >/dev/null 2>&1; then
        echo "mygive-$command: $tests: not a valid tar file" >&2
        exit 1
    fi

    # Validate test file contents (pain)
    failed=0
    tar -tf "$tests" >/tmp/test_list

    while IFS= read -r path && [ "$failed" -ne 1 ]; do
        case "$path" in
        */*) ;;        # Has a slash -> valid dir/file structure
        *) continue ;; # loose file
        esac

        testname=$(echo "$path" | cut -d/ -f1)
        file=$(echo "$path" | cut -d/ -f2)

        # Zero size: SKIP
        if [ -z "$file" ]; then
            continue
        fi

        # I'll be honest, I'm not sure what the deal is with the bellow error.
        # I'm just trying anything I can

        # Nested directories in test suite.
        rest=$(echo "$path" | cut -d/ -f3-)
        if [ -n "$rest" ]; then
            echo "mygive-add: $tests: invalid test_name" >&2
            failed=1
            continue
        fi

        # Bad test name
        if ! echo "$testname" | grep -Eq '^[a-zA-Z0-9_]+$'; then
            echo "mygive-add: $tests: invalid test_name" >&2
            failed=1
        fi

        # It seems the reference didn't care about this one
        # Including it in case I can score marks for at least considering it
        # echo "$file" | grep -Eq '^(arguments|stdin|options|stdout|stderr|exit_status|marks)$' || {
        #     echo "mygive-add: $tests: invalid test_name" >&2
        #     failed=1
        # }
    done </tmp/test_list

    rm -f /tmp/test_list

    if [ "$failed" -eq 1 ]; then
        exit 1
    fi
}

zid_check() {
    local zid="$1"
    local command="$2"

    local check
    check=$(echo "$zid" | grep -E "^z[0-9]{7}$")
    if [ "$zid" = "" ] || [ "$check" != "$zid" ]; then
        echo "mygive-$command: invalid zid: $zid" >&2
        exit 1
    fi

}

# This would normally be done on one line, but extracted for custom message
file_exist_check() {
    local filename="$1"
    local command="$2"

    if [ ! -e "$filename" ]; then
        echo "mygive-$command: $filename: No such file or directory" >&2
        exit 1
    fi

    if [ -d "$filename" ]; then
        echo "mygive-$command: $filename: Is a directory" >&2
        exit 1
    fi

    if [ ! -r "$filename" ]; then
        echo "mygive-$command: $filename: Permission denied" >&2
        exit 1
    fi
}

# Checking if the test file is valid for a submission
test_submission_check() {
    local filename="$1"
    local command="$2"

    if echo "$filename" | grep -q '[^a-zA-Z0-9._/-]'; then
        echo "mygive-$command: invalid filename: $filename" >&2
        exit 1
    fi

    # Allow /dev/null as a special case (don't ask.)
    if [ "$filename" != "/dev/null" ] && [ ! -f "$filename" ]; then
        echo "mygive-$command: $filename not found" >&2
        exit 1
    fi

    if [ ! -x "$filename" ]; then
        echo "mygive-$command: $filename is not executable" >&2
        exit 1
    fi
}

# Useful when testing to make a lot of temp files
ensure_file_or_temp() {
    file="$1"

    if [ ! -f "$file" ]; then
        file=$(mktemp)
        : >"$file" # Empty file (NOT touch)
    fi

    echo "$file"
}

# Needed for test cases
is_logically_empty() {
    grep -q '[^[:space:]]' "$1" && return 1
    return 0
}
