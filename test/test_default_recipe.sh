#!/bin/bash

assert_output "bake -q -f ./bakefiles/default_recipe__missing.bakefile" "$(
	cat <<-EXPECTED
		Nothing to do!
	EXPECTED
)"

assert_output "bake -q -f ./bakefiles/default_recipe.bakefile" "$(
	cat <<-EXPECTED
		Default recipe.
	EXPECTED
)"

skip assert_output "bake -q -f ./bakefiles/default_recipe__multiple.bakefile" "$(
	cat <<-EXPECTED
		Nothing to do!
	EXPECTED
)"
