#!/bin/bash

assert_stderr "TERM= bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/default_recipe__missing.bakefile'" "$(
	cat <<-EXPECTED
		bake: Nothing to do!
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/default_recipe.bakefile'" "$(
	cat <<-EXPECTED
		Default recipe.
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/default_recipe__subprocess.bakefile'" "$(
	cat <<-EXPECTED
		Default subprocess recipe.
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/default_recipe__with_arguments.bakefile'" "$(
	cat <<-EXPECTED
		Default recipe: \$1=arg1 - \$2=arg2
	EXPECTED
)"

assert_stderr "TERM= bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/default_recipe__multiple.bakefile'" "$(
	cat <<-EXPECTED
		bake: Too many default recipes!
	EXPECTED
)"

assert_stderr "TERM= bake -q -f '${__TEST_BAKEFILES_PATH__}/annotations/default_recipe__multiple_with_arguments.bakefile'" "$(
	cat <<-EXPECTED
		bake: Too many default recipes!
	EXPECTED
)"
