#!/bin/bash

assert_stderr "TERM= bake -- -h" "$(
	cat <<-EXPECTED
		bake: No recipe '-h'!
	EXPECTED
)"
