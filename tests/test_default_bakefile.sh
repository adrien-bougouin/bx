#!/bin/bash

DIRECTORY="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

assert_stdout "cd '${DIRECTORY}' && bake -q which-bakefile" "$(
	cat <<-EXPECTED
		${DIRECTORY}/Bakefile
	EXPECTED
)"
