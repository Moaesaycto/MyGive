#!/bin/dash

# ============================================================
#                   TESTING mygive-* (1)
# ============================================================

# Setting up the course
block1='
mygive-add assignment1 provided_tests/multiply.tests
mygive-add assignment2 provided_tests/hello.tests
mygive-summary
'

# Students start testing and submitting
block2='
mygive-submit assignment1 z1111111 provided_tests/multiply_wrong.sh
mygive-submit assignment1 z1111111 provided_tests/multiply_wrong.sh
mygive-submit assignment1 z2222222 provided_tests/multiply_wrong.sh
mygive-submit assignment1 z222222 provided_tests/multiply_wrong.sh
mygive-submit assignment1 22222222 provided_tests/multiply_wrong.sh
mygive-test assignment1 provided_tests/multiply_wrong.sh
mygive-test assignment1 provided_tests/multiply.sh
mygive-submit assignment1 z2222222 provided_tests/multiply_wrong.sh
mygive-submit assignment1 z1111111 provided_tests/wrong.sh

mygive-submit assignment2 z1111111 provided_tests/hello.sh
mygive-submit assignment2 z2222222 provided_tests/hello.sh
mygive-test assignment2 provided_tests/hello.sh
mygive-submit assignment2 z2222222 provided_tests/grep.sh
mygive-submit assignment2 z3333333 /dev/null
'

# Fetching, status and summary 
block3='
mygive-summary
mygive-status z1111111
mygive-status z2221111
mygive-status z2222222

mygive-fetch adding z1111111
mygive-fetch multiply z1111111
mygive-fetch multiply z1111111 0
mygive-fetch multiply z1111111 -1
mygive-fetch multiply z1111111 2
mygive-fetch multiply z1111111 4

mygive-fetch assignment2 z1111111
mygive-fetch assignment2 z3333333
'

# Further testing and marking
block4='
mygive-test assignment1 provided_tests/hello.sh
mygive-test assignment1 provided_tests/grep_wrong.sh
mygive-test assignment1 provided_tests/grep.sh
mygive-test assignment2 provided_tests/hello.sh
mygive-test assignment2 provided_tests/grep.sh

mygive-summary
mygive-mark assignment1
mygive-mark assignment2
'

# Assignment1 is over.
block5='
mygive-rm assignment1
'

# Assignment2 is over.
block6='
mygive-rm assignment2
'

block7='
mygive-summary
mygive-status z1111111
'

tests="
$block1
$block2
$block3
$block4
$block5
$block6
$block7
"

./_tester.sh 8 "$tests"