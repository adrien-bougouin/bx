#!/bin/bash

assert_output "bake -q -f '${__BAKEFILES__}/recipe_sequence.bakefile' one three three seven" "$(
	cat <<-EXPECTED
		1337
	EXPECTED
)"

assert_output "bake -q -f '${__BAKEFILES__}/recipe_sequence.bakefile' one 'three 2' seven" "$(
	cat <<-EXPECTED
		1337
	EXPECTED
)"
