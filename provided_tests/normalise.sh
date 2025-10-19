#!/bin/dash

input=$(cat)

if [ -z "$input" ]; then
    echo "normalise: no input provided" >&2
    exit 1
fi

trimmed=$(echo "$input" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

normalised=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]')

echo "$normalised"
exit 0
