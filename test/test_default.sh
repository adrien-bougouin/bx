#!/bin/bash

assert_output "bake --list" "$(
  cat <<-EXPECTED
		Recipes:
		- recipe_1
		recipe_1 () 
		{ 
		    true
		}
		- recipe_2
		recipe_2 () 
		{ 
		    true
		}
	EXPECTED
)"
