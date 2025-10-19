#!/bin/dash

# ============================================================
#                   TESTING mygive-summary
# ============================================================
# FAKETIME doesn't work for some reason, so if you get an
# error, rerun the test to make sure it is consistently wrong
# (or just check the output folder if you aren't lazy)

# Wrong number of arguments
block1='
mygive-summary goop
mygive-summary goopy boopy
mygive-summary spaghetti on the slide please
mygive-summary --mayhaps --
mygive-summary --may
mygive-summary --
mygive-summary ""
mygive-summary "" "" --
mygive-summary - z5319858
mygive-summary project -
'

# Nothing at all
block2='
mygive-summary
'

# Bad arguments
block3='
mygive-add project1 provided_tests/hello.tests
mygive-add project2 provided_tests/hello.tests
mygive-add project3 provided_tests/hello.tests
mygive-submit project1 z1111111 dummy.txt
mygive-submit project1 z1111111 dummy.txt
mygive-submit project2 z1111111 dummy.txt
mygive-submit project3 z1111111 dummy.txt
mygive-submit project3 z1111111 dummy.txt
mygive-submit project3 z1111111 dummy.txt
mygive-submit project3 z1111111 dummy.txt
mygive-submit project1 z2222222 dummy.txt
mygive-submit project3 z1111111 dummy.txt
mygive-submit project3 z2222222 dummy.txt
mygive-submit project3 z3333333 dummy.txt
mygive-summary
'

# Empty Assignment
block4='
mygive-add empty provided_tests/hello.tests
mygive-summary
'

tests="$block1
$block2
$block3
$block4
"

./_tester.sh 2 "$tests"