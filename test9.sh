#!/bin/dash

# ============================================================
#                   TESTING mygive-* (2)
# ============================================================

# Setting up the course (clumsily)
block1='
mygive-add
mygive-add assignment1
mygive-add assignment1 thisdoesnotexist.tar
mygive-add assignment1 provided_tests/invalid@name.tests
mygive-add 123 provided_tests/hello.tests
mygive-add assignment1/extra provided_tests/hello.tests
mygive-add -weirdflag provided_tests/hello.tests
mygive-add provided_tests/hello.tests

mygive-submit
mygive-submit assignment1
mygive-submit assignment1 z1234567
mygive-submit assignment1 z1234567 not/a/real/file.sh
mygive-submit assignment1 z1234567 /dev/null
mygive-submit assignment1 z!@#$% provided_tests/hello.sh
mygive-submit assignment1 provided_tests/hello.sh
mygive-submit z1234567 provided_tests/hello.sh
mygive-submit assignment1 z1234567

mygive-test
mygive-test assignment1
mygive-test assignment1 not_a_file.sh
mygive-test assignment1 execute.sh
mygive-test assignment1 /etc/passwd

mygive-mark
mygive-mark 1assignment
mygive-mark .hidden

mygive-status
mygive-status z0000000
mygive-status z123456789123456789

mygive-fetch
mygive-fetch assignment1
mygive-fetch assignment1 z1234567 extra_argument
mygive-fetch assignment1 z1234567 -9999
mygive-fetch assignment1 z1234567 9999
mygive-fetch assignment1 z1234567 nonsense

mygive-summary nonsense
'

# Minimal setup to allow some commands to partially function
block2='
mygive-add assignment1 provided_tests/hello.tests
mygive-submit assignment1 z0000000 provided_tests/hello.sh
'

# Trying to delete nonsense assignments
block3='
mygive-rm
mygive-rm random
mygive-rm .hiddenfile
mygive-rm assignment1/extra
'

# Submissions from non-standard users and repeated misuse
block4='
mygive-submit assignment1 user@domain provided_tests/hello.sh
mygive-submit assignment1 z1234567 provided_tests/hello.sh
mygive-submit assignment1 z1234567 provided_tests/hello.sh
mygive-submit assignment1 z1234567 provided_tests/hello_wrong0.sh
mygive-status z1234567
mygive-fetch assignment1 z1234567
mygive-mark assignment1
'

tests="
$block1
$block2
$block3
$block4
"

./_tester.sh 9 "$tests"