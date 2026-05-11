#!/bin/bash

assert_stderr "TERM= bake -q -f '${__BAKEFILES__}/default_recipe__missing.bakefile'" "$(
	cat <<-EXPECTED
		bake: Nothing to do!
	EXPECTED
)"

assert_stdout "bake -q -f '${__BAKEFILES__}/default_recipe.bakefile'" "$(
	cat <<-EXPECTED
		Default recipe.
	EXPECTED
)"

assert_stdout "bake -q -f '${__BAKEFILES__}/default_recipe__subprocess.bakefile'" "$(
	cat <<-EXPECTED
		Default subprocess recipe.
	EXPECTED
)"

assert_stderr "TERM= bake -q -f '${__BAKEFILES__}/default_recipe__multiple.bakefile'" "$(
	cat <<-EXPECTED
		bake: Too many default recipes!
	EXPECTED
)"
