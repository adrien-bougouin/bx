#!/bin/bash

HELP_MESSAGE="$(
	cat <<-HELP
		Usage: bake [options] [--] [recipe] ...

		Options:
		    -f FILE, --file FILE, --bakefile FILE
		       Read FILE as a bakefile.
		    -h, --help
		       Show this help.
		    -l, --list
		       Show the available recipes.
		    -s, --silent, -q, --quiet
		       Do not display the executed recipe name and arguments.
	HELP
)"

readonly HELP_MESSAGE

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/help__no_recipe.bakefile' -h" "$(
	cat <<-EXPECTED
		${HELP_MESSAGE}
	EXPECTED
)"

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/DOES_NOT_EXIST.bakefile' -h" "$(
	cat <<-EXPECTED
		${HELP_MESSAGE}
	EXPECTED
)"

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/help.bakefile' -h" "$(
	cat <<-EXPECTED
		${HELP_MESSAGE}

		Available recipes:
		    recipe_1
		    recipe_2
		    recipe_3
	EXPECTED
)"

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/help.bakefile' --help" "$(
	cat <<-EXPECTED
		${HELP_MESSAGE}

		Available recipes:
		    recipe_1
		    recipe_2
		    recipe_3
	EXPECTED
)"
