#!/bin/bash

CURRENT_DIRECTORY="$(realpath $(dirname "${BASH_SOURCE[0]}"))"

assert_output "bake -q -f './bakefiles/remote.bakefile' which-bakefile" "$(
  cat <<-EXPECTED
		${CURRENT_DIRECTORY}/bakefiles/remote.bakefile
	EXPECTED
)"

assert_output "bake -q --file './bakefiles/remote.bakefile' which-bakefile" "$(
  cat <<-EXPECTED
		${CURRENT_DIRECTORY}/bakefiles/remote.bakefile
	EXPECTED
)"

assert_output "bake -q --bakefile './bakefiles/remote.bakefile' which-bakefile" "$(
  cat <<-EXPECTED
		${CURRENT_DIRECTORY}/bakefiles/remote.bakefile
	EXPECTED
)"
