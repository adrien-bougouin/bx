#!/bin/bash

assert_stderr "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/options/DOES_NOT_EXIST.bakefile'" "$(
	cat <<-EXPECTED
		bake: No recipes!
	EXPECTED
)"
