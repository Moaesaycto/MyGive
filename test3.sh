#!/bin/dash

# ============================================================
#                   TESTING mygive-status
# ============================================================

# Wrong number of arguments
block1='
mygive-status
mygive-status ""
mygive-status --
mygive-status -
mygive-status z5319858 extra
mygive-status z5319858 burn baby burn
mygive-status -- z5319858
mygive-status "" z5319858
mygive-status z5319858 --
mygive-status z5319858 --4
mygive-status z5319858 -
'

# Invalid zID formats
block2='
mygive-status 5319858
mygive-status x1234567
mygive-status z12345
mygive-status 1234567z
mygive-status z123456
mygive-status z12345678
mygive-status z!@#$$%^
'

# A hefty case
block3='
mygive-add a1 provided_tests/hello.tests
mygive-add a2 provided_tests/hello.tests
mygive-add a3 provided_tests/hello.tests

mygive-submit a1 z5000000 dummy.txt
mygive-submit a1 z5000000 dummy.txt
mygive-submit a1 z5000000 dummy.txt

mygive-submit a1 z5111111 dummy.txt

mygive-submit a2 z5111111 dummy.txt
mygive-submit a2 z5111111 dummy.txt

mygive-submit a3 z5111111 dummy.txt
mygive-submit a3 z5111111 dummy.txt
mygive-submit a3 z5111111 dummy.txt
mygive-submit a3 z5111111 dummy.txt

mygive-submit a3 z5222222 dummy.txt

mygive-status z5111111
mygive-status z5000000
mygive-status z5222222
mygive-status z5999999
'

tests="$block1
$block2
$block3
"

./_tester.sh 3 "$tests"