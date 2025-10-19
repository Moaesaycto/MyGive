#!/bin/dash

# ============================================================
#                   TESTING mygive-fetch
# ============================================================

# Wrong number of arguments
block1='
mygive-fetch
mygive-fetch assignment1
mygive-fetch "" assignment1
mygive-fetch -- assignment1
mygive-fetch - assignment1
mygive-fetch assignment1 --
mygive-fetch assignment1 ""
mygive-fetch assignment1 -
mygive-fetch assignment1 "" 0
mygive-fetch assignment1 z5111111 breathe manually now
mygive-fetch assignment1 z5111111 --
mygive-fetch assignment1 z5111111 --3
'

# Invalid assignment or zid formats
block2='
mygive-fetch 123invalid z5111111
mygive-fetch .assignment z5111111
mygive-fetch assignment1 5111111
mygive-fetch assignment1 invalidzid
mygive-fetch assignment1 z!@#$
'

# Bad submission indexes (or is it indices?)
block3='
mygive-add assignment1 provided_tests/hello.tests
mygive-submit assignment1 z5111111 dummy.txt
mygive-submit assignment1 z5111111 dummy.txt

mygive-fetch assignment1 z5111111 10
mygive-fetch assignment1 z5111111 -10
mygive-fetch assignment1 z5111111 notanumber
mygive-fetch assignment1 z5111111 1.5
'

# No submissions exist
block4='
mygive-add assignment2 provided_tests/hello.tests
mygive-fetch assignment2 z5222222
'

# Valid fetches
block5='
mygive-submit assignment2 z5222222 dummy.txt
mygive-submit assignment2 z5222222 dummy.txt
mygive-submit assignment2 z5222222 dummy.txt
mygive-submit assignment2 z5222222 dummy.txt
mygive-fetch assignment2 z5222222
mygive-fetch assignment2 z5222222 1
mygive-fetch assignment2 z5222222 2
mygive-fetch assignment2 z5222222 3
mygive-fetch assignment2 z5222222 4
mygive-fetch assignment2 z5222222 0
mygive-fetch assignment2 z5222222 -1
mygive-fetch assignment2 z5222222 -2
mygive-fetch assignment2 z5222222 -3
mygive-fetch assignment2 z5222222 -4
'

tests="$block1
$block2
$block3
$block4
$block5
"

./_tester.sh 4 "$tests"