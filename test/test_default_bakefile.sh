#!/bin/bash

DIRECTORY="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

assert_output "cd '${DIRECTORY}' && bake -q which-bakefile" "$(
	cat <<-EXPECTED
		${DIRECTORY}/Bakefile
	EXPECTED
)"
