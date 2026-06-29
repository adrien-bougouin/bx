#!/bin/bash

assert_stdout "cd '${__TEST_PATH__}/bakefiles/bakefile' && bake -q which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__TEST_PATH__}")/bakefiles/bakefile/Bakefile
	EXPECTED
)"
