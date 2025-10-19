#!/bin/dash

case "$1" in
0)
    echo the
    echo
    echo "ANSWER is  42"
    ;;
1)
    echo " The "
    echo "  "
    echo "answer    is 42 "
    ;;
2)
    echo The
    echo "answer is  42"
    echo
    ;;
3)
    echo There is extra
    echo text here
    echo "but answer is still 42"
    ;;
4)
    echo THE
    echo "answer  is 42"
    echo
    ;;
*)
    echo The
    echo
    echo "answer is  42"
esac