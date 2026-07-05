#!/bin/bash

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/list__no_recipe.bakefile' -l" ""

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/list.bakefile' -l" "$(
	cat <<-EXPECTED
		Available recipes:
		    recipe_1
		    recipe_2
		    recipe_3
	EXPECTED
)"

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/DOES_NOT_EXIST.bakefile' -l" "$(
	cat <<-EXPECTED
	EXPECTED
)"
