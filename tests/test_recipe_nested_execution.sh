#!/bin/bash

assert_stdout "TERM= bake -f '${__BAKEFILES__}/recipe_nested_execution.bakefile' 'r-exec r-executed'" "$(
	cat <<-EXPECTED
		r-exec r-executed
		Executing 'r-executed'
		r-executed
		- r-executed
	EXPECTED
)"
