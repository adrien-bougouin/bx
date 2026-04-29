#!/bin/bash

assert_output "TERM= bake -q -f ./bakefiles/default_recipe__missing.bakefile" "$(
	cat <<-EXPECTED
		bake: Nothing to do!
	EXPECTED
)"

assert_output "bake -q -f ./bakefiles/default_recipe.bakefile" "$(
	cat <<-EXPECTED
		Default recipe.
	EXPECTED
)"

assert_output "TERM= bake -q -f ./bakefiles/default_recipe__multiple.bakefile" "$(
	cat <<-EXPECTED
		bake: Too many default recipes!
	EXPECTED
)"
