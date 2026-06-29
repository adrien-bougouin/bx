#!/bin/bash

assert_stdout "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/recipe/nested_execution.bakefile' 'r-exec r-executed'" "$(
	cat <<-EXPECTED
		r-exec r-executed
		Executing 'r-executed'
		r-executed
		- r-executed
	EXPECTED
)"
