#!/bin/bash

assert_stdout "bake -q -f '${__TEST_BAKEFILES__}/recipe_sequence.bakefile' one three three seven" "$(
	cat <<-EXPECTED
		1337
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES__}/recipe_sequence.bakefile' one 'three 2' seven" "$(
	cat <<-EXPECTED
		1337
	EXPECTED
)"
