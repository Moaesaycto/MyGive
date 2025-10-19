#!/bin/dash

# ============================================================
#                    TESTING mygive-test
# ============================================================
# Absolute bitch of a test to pass
# 13 and 14 don't pass, but that's because the "Permission denied"
# error starts with "/bin/sh:" and not "./mygive-test"

touch secret.sh
chmod 000 secret.sh
touch execute.sh
chmod 111 execute.sh
touch _bad_bad_file.py

# Wrong number of arguments
block1='
mygive-test
mygive-test project
mygive-test project once upon a villain
mygive-test project dummy.txt --
mygive-test project dummy.txt -
mygive-test project dummy.txt --3
mygive-test project dummy.txt ""
mygive-test "" dummy.txt
mygive-test -- dummy.txt
mygive-test - dummy.txt
mygive-test --project dummy.txt
mygive-test project --
mygive-test project ""
mygive-test project --3
mygive-test project --aaaaaa
mygive-test project -
'

# Wrong assignment
block2='
mygive-test project dummy.txt
mygive-test 1project dummy.txt
mygive-test Project dummy.txt
mygive-test project@-ed dummy.txt
'

# Submission files from hell
block3='
mygive-add hello provided_tests/hello.tests
mygive-test hello dummy.txt
mygive-test hello idontexistlol.txt
mygive-test hello /dev/null
mygive-test hello secret.sh
mygive-test hello execute.sh
mygive-test hello execute.sh
mygive-test hello _bad_bad_file.py
'

# Setting up all the tests
block4='
mygive-add answer provided_tests/answer.tests
mygive-add grep provided_tests/grep.tests
mygive-add hello provided_tests/hello.tests
mygive-add multiply provided_tests/multiply.tests
mygive-add stderr provided_tests/stderr.tests
mygive-add normalise provided_tests/normalise_test
'

# I tried to make my own test :)
block5='
mygive-test normalise provided_tests/normalise.sh
mygive-test answer provided_tests/normalise.sh
'

# F*ck it: every possible combination
assignments="answer grep hello multiply stderr normalise"
scripts="answer.sh
answer_wrong.sh
grep.sh
grep_wrong.sh
hello.sh
hello_wrong0.sh
multiply.sh
multiply_wrong.sh
stderr.sh
stderr_wrong.sh
normalise.sh"

block6=""
for assignment in $assignments; do
    for script in $scripts; do
        block6="${block6}mygive-test $assignment provided_tests/$script\n"
    done
done

tests="$block1
$block2
$block3
$block4
$block5
$block6
"

./_tester.sh 5 "$tests"

chmod u+w secret.sh
chmod u+w execute.sh
rm "secret.sh" "_bad_bad_file.py"