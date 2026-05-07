#!/bin/bash

assert_output "bake -q -f '${__BAKEFILES__}/recipe_globals.bakefile' show-globals" "$(
	cat <<-EXPECTED
		- GLOBAL_STRING=global-string
		- GLOBAL_ARRAY=global-arr-1 global-arr-2 global-arr-3
	EXPECTED
)"

assert_output "bake -q -f '${__BAKEFILES__}/recipe_globals.bakefile' show-globals--subprocess" "$(
	cat <<-EXPECTED
		- GLOBAL_STRING=global-string
		- GLOBAL_ARRAY=global-arr-1 global-arr-2 global-arr-3
	EXPECTED
)"
