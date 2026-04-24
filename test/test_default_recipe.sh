#!/bin/bash

assert_output "bake -q -f ./bakefiles/no_default_recipe.bakefile" "$(
	cat <<-EXPECTED
		Nothing to do!
	EXPECTED
)"

assert_output "bake -q -f ./bakefiles/default_recipe.bakefile" "$(
	cat <<-EXPECTED
		Default recipe.
	EXPECTED
)"

skip assert_output "bake -q -f ./bakefiles/too_many_default_recipes.bakefile" "$(
	cat <<-EXPECTED
		Nothing to do!
	EXPECTED
)"
