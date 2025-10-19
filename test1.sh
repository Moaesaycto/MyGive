#!/bin/dash

# ============================================================
#                    TESTING mygive-submit
# ============================================================

# Sometimes it bugs out with the time checking. I added in a
# FAKETIME command that I don't think works. If there is a
# discrepancy I will check it manually

touch secret.sh
chmod 000 secret.sh

# Wrong number of arguments
block1='
mygive-submit
mygive-submit wrong
mygive-submit wrong number
mygive-submit wrong number of arguments
mygive-submit wrong number of arguments blah blah blah blah blah
mygive-submit --right --number --params
mygive-submit -- z5554443 dummy.txt
mygive-submit project 5319858 dummy.txt --oopsie
mygive-submit project "" dummy.txt
mygive-submit "" z5319858 dummy.txt
mygive-submit dummy z5319858 ""
mygive-submit dummy z5319858 -

'

# Bad arguments
block2='
mygive-add project provided_tests/hello.tests
mygive-submit .wrong z5319858 dummy.txt
mygive-submit nothere z5319858 dummy.txt
mygive-submit project 5319858 dummy.txt
mygive-submit project x1234567 dummy.txt
mygive-submit project z12345 dummy.txt
mygive-submit project 1234567z dummy.txt
mygive-submit project z123456 dummy.txt
mygive-submit project z12345678 dummy.txt
mygive-submit project !@#$$%^ dummy.txt
mygive-submit project foobar dummy.txt
mygive-submit project z5319858 doesntexist.py
mygive-submit /dev/null z5319858 dummy.txt
mygive-submit project /dev/null dummy.txt
mygive-submit project z5319858 /dev/null
mygive-submit project z5319858 provided
'

black3='
mygive-submit project z5319858 dummy.txt
'

# Locked file (no reading, no executing)
block4='
mygive-submit project z5319858 secret.sh
'

tests="$block1
$block2
$block3
$block4
"

./_tester.sh 1 "$tests"

chmod u+w secret.sh
rm "secret.sh"