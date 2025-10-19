#!/bin/dash

# ============================================================
#                      TESTING mygive-rm
# ============================================================

# Wrong number of arguments
block1='
mygive-rm
mygive-rm all escapes start with the click of a lock
'

# Invalid assignment names
block2='
mygive-rm assignment
mygive-rm 1assignment
mygive-rm eggs@in@pasta?
mygive-rm --weird
mygive-rm -weird
mygive-rm ""
mygive-rm -
'

# Add, remove, re-add basic
block3='
mygive-add assignment1 provided_tests/hello.tests
mygive-rm assignment1
mygive-add assignment1 provided_tests/hello.tests
'

# Multiple adds and removals
block4='
mygive-add a1 provided_tests/hello.tests
mygive-add a2 provided_tests/hello.tests
mygive-add a3 provided_tests/hello.tests

mygive-rm a2
mygive-rm a1

mygive-add a1 provided_tests/hello.tests
mygive-add a2 provided_tests/hello.tests
mygive-rm a3
'

# Remove non-existent assignments
block5='
mygive-rm not_real
mygive-rm ghost123
'

# Submit files, then try to remove assignment
block6='
mygive-add testremove provided_tests/hello.tests
mygive-submit testremove z1111111 provided_tests/hello.sh
mygive-submit testremove z2222222 provided_tests/hello_wrong0.sh

mygive-rm testremove
mygive-add testremove provided_tests/hello.tests
'

# Try removing twice
block7='
mygive-add repeat provided_tests/hello.tests
mygive-rm repeat
mygive-rm repeat
'

# Put all together
tests="
$block1
$block2
$block3
$block4
$block5
$block6
$block7
"

./_tester.sh 7 "$tests"