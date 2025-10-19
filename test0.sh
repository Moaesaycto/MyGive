#!/bin/dash

# ============================================================
#                      TESTING mygive-add
# ============================================================

# TO MARKER:
#   These are just the raw commands that are passed in. Please
#   refer to the _tester.sh file to see how it works.

# Making some bad test files
mkdir -p temp_dir

# Very wrong
mkdir temp_dir/test_invalid_file
echo "echo hello" >temp_dir/test_invalid_file/invalid.sh
tar -cf dud_invalid_file.tar -C temp_dir test_invalid_file

# Generic example
mkdir temp_dir/test_badname
echo "some test" >temp_dir/test_badname/WRONGFILE
tar -cf dud_badname.tar -C temp_dir test_badname

# This one breaks the reference.
# Posted on the forum:
# https://discourse01.cse.unsw.edu.au/25T2/COMP2041/t/discovered-error-in-references-mygive-add/438
mkdir temp_dir/test_overload
touch temp_dir/test_overload/arguments temp_dir/test_overload/stdin \
      temp_dir/test_overload/options temp_dir/test_overload/stdout \
      temp_dir/test_overload/stderr temp_dir/test_overload/exit_status \
      temp_dir/test_overload/marks temp_dir/test_overload/extra_file
tar -cf dud_overload.tar -C temp_dir test_overload
tar -cf dud_empty.tar --files-from=/dev/null

# Loose file in main test folder
echo "not in directory" >temp_dir/loose_file.txt
tar -cf dud_loose_file.tar -C temp_dir loose_file.txt

# Basic testing for regex
mkdir -p temp_dir/bad@testname
touch temp_dir/bad@testname/stdout
touch temp_dir/bad@testname/stderr
tar -cf dud_illegal_dirname.tar -C temp_dir bad@testname

# Nested dirs
mkdir -p temp_dir/weird_test/stdout/extra
echo "test" >temp_dir/weird_test/stdout/extra/file.txt
tar -cf dud_nested.tar -C temp_dir weird_test

# Wrong argument amounts
block1='
mygive-add
mygive-add test
mygive-add test test
mygive-add test test test test test test test test test test test test test test test
mygive-add assignment --test 
mygive-add --womp --womp
mygive-add -- -
mygive-add valid -
mygive-add valid ""
mygive-add "" provided_tests/answer.tests
mygive-add - provided_tests/answer.tests
mygive-add assignment ""
mygive-add --assignment provided_tests/answer.tests
mygive-add assignment_dud provided_tests/answer.tests --remove
'

# Invalid assignment names
block2='
mygive-add 1assignment provided_tests/answer.tests
mygive-add _assignment provided_tests/answer.tests
mygive-add Assignment provided_tests/answer.tests
mygive-add assign-ment provided_tests/answer.tests
mygive-add assign.ment provided_tests/answer.tests
mygive-add assign@ment provided_tests/answer.tests
mygive-add assign/ment provided_tests/hello.tests
'

# Faulty Tests
block3='
mygive-add valid1 nonexistent.tests
mygive-add valid2 /
mygive-add valid3 /dev/null
mygive-add valid4 some_directory/
mygive-add valid5 "some weird!path/tests?.tar"
mygive-add valid6 dummy.txt
mygive-add "assignment " provided_tests/hello.tests
mygive-add dud1 dud_invalid_file.tar #19
mygive-add dud2 dud_badname.tar #20
mygive-add dud3 dud_overload.tar #21
mygive-add dud4 dud_empty.tar #22
mygive-add dud5 dud_loose_file.tar #23
mygive-add dud6 dud_illegal_dirname.tar #24
mygive-add dud7 dud_nested.tar
'

# Double-up of the same assignment
block4='
mygive-add assignment1 provided_tests/hello.tests
mygive-add assignment1 provided_tests/hello.tests
mygive-add assignment1 provided_tests/hello.tests
mygive-add assignment1 provided_tests/hello.tests
'

# More, more, MORE!
block5='
mygive-add assignment2 provided_tests/hello.tests
mygive-add assignment3 provided_tests/hello.tests
mygive-add assignment4 provided_tests/hello.tests
mygive-add assignment5 provided_tests/hello.tests
mygive-add assignment6 provided_tests/hello.tests
mygive-add a provided_tests/hello.tests
mygive-add a12345678901234567890 provided_tests/hello.tests
'

tests="$block1
$block2
$block3
$block4
$block5"

./_tester.sh 0 "$tests"

rm -rf temp_dir
rm -f dud_*.tar