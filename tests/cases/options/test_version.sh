#!/bin/bash

assert_stdout "TERM= bake -v" "$(
	cat <<-EXPECTED
		bake: ${__BAKE_CONSTANT_VERSION__}
	EXPECTED
)"
