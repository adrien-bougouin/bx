#!/bin/bash

assert_output "bake --help" "$(
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
	EXPECTED
)"
