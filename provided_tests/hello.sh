#!/bin/dash
i="$1"
test -n "$i" || exit 0
echo -n "Hello COMP2041 and Hello COMP9044"
while  test "$i" -gt 0
do
    i=$((i - 1))
    echo
done
