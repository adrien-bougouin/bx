#!/bin/bash

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/bakefile/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__TEST_BAKEFILES_PATH__}/bakefile/remote.bakefile")
	EXPECTED
)"

assert_stdout "bake -q --file '${__TEST_BAKEFILES_PATH__}/bakefile/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__TEST_BAKEFILES_PATH__}/bakefile/remote.bakefile")
	EXPECTED
)"

assert_stdout "bake -q --bakefile '${__TEST_BAKEFILES_PATH__}/bakefile/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__TEST_BAKEFILES_PATH__}/bakefile/remote.bakefile")
	EXPECTED
)"
