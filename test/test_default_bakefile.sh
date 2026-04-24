#!/bin/bash

CURRENT_DIRECTORY="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

assert_output "bake -q which-bakefile" "$(
	cat <<-EXPECTED
		${CURRENT_DIRECTORY}/Bakefile
	EXPECTED
)"
