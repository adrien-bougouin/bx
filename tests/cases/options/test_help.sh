#!/bin/bash

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/help__no_recipe.bakefile' -h" "$(
	cat <<-EXPECTED
		Usage: bake [options] [recipe] ...

		Options:
		    -f FILE, --file FILE, --bakefile FILE
		       Read FILE as a bakefile.
		    -h, --help
		       Show this help.
	EXPECTED
)"

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/DOES_NOT_EXIST.bakefile' -h" "$(
	cat <<-EXPECTED
		Usage: bake [options] [recipe] ...

		Options:
		    -f FILE, --file FILE, --bakefile FILE
		       Read FILE as a bakefile.
		    -h, --help
		       Show this help.
	EXPECTED
)"

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/help.bakefile' -h" "$(
	cat <<-EXPECTED
		Usage: bake [options] [recipe] ...

		Options:
		    -f FILE, --file FILE, --bakefile FILE
		       Read FILE as a bakefile.
		    -h, --help
		       Show this help.

		Available recipes:
		    recipe_1
		    recipe_2
		    recipe_3
	EXPECTED
)"

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/help.bakefile' --help" "$(
	cat <<-EXPECTED
		Usage: bake [options] [recipe] ...

		Options:
		    -f FILE, --file FILE, --bakefile FILE
		       Read FILE as a bakefile.
		    -h, --help
		       Show this help.

		Available recipes:
		    recipe_1
		    recipe_2
		    recipe_3
	EXPECTED
)"
