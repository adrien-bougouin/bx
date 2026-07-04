#!/bin/bash

assert_stdout "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/recipe/execution.bakefile' -q recipe" "$(
	cat <<-EXPECTED
		- recipe
	EXPECTED
)"

assert_stderr "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/recipe/execution.bakefile' -q missing" "$(
	cat <<-EXPECTED
		bake: No recipe 'missing'!
	EXPECTED
)"
