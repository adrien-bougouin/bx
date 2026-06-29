#!/bin/bash

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/recipe_arguments.bakefile' 'count-args'" "$(
	cat <<-EXPECTED
		0 argument(s)
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/recipe_arguments.bakefile' 'count-args a'" "$(
	cat <<-EXPECTED
		1 argument(s)
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/recipe_arguments.bakefile' 'count-args a b'" "$(
	cat <<-EXPECTED
		2 argument(s)
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/recipe_arguments.bakefile' 'count-args a b c'" "$(
	cat <<-EXPECTED
		3 argument(s)
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/recipe_arguments.bakefile' \"count-args 'a b c'\"" "$(
	cat <<-EXPECTED
		1 argument(s)
	EXPECTED
)"
