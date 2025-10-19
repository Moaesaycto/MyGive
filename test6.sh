#!/bin/dash

# ============================================================
#                    TESTING mygive-mark
# ============================================================

# Wrong # of arguments again
block1='
mygive-mark
mygive-mark sick of this
'

# Bad assignments
block2='
mygive-mark 123invalid
mygive-mark .hidden
mygive-mark assignment!
mygive-mark "hello world"
mygive-mark ""
mygive-mark -
mygive-mark --
mygive-mark --boogie
mygive-mark --123
'

# Setting up for a proper go
block3='
mygive-add multiply provided_tests/multiply.tests

mygive-submit multiply z1234567 provided_tests/multiply_wrong.sh
mygive-submit multiply z1233333 provided_tests/multiply_wrong.sh
mygive-submit multiply z1233333 provided_tests/multiply_wrong.sh
mygive-submit multiply z1233333 provided_tests/multiply.sh
mygive-submit multiply z1234443 provided_tests/multiply.sh
mygive-submit multiply z9191919 provided_tests/grep.sh
'

# Here we go....
block4='
mygive-mark multiply
'

# An assignment with no submissions
block5='
mygive-add grep provided_tests/grep.tests
mygive-mark grep
'

# A student submits /dev/null
block6='
mygive-add hello provided_tests/hello.tests
mygive-submit hello z5319858 /dev/null
mygive-mark hello
'

tests="
$block1
$block2
$block3
$block4
$block5
$block6"

./_tester.sh 6 "$tests"