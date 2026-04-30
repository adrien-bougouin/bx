#!/bin/bash

assert_output "bake -q -f '${__BAKEFILES__}/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__BAKEFILES__}/remote.bakefile")
	EXPECTED
)"

assert_output "bake -q --file '${__BAKEFILES__}/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__BAKEFILES__}/remote.bakefile")
	EXPECTED
)"

assert_output "bake -q --bakefile '${__BAKEFILES__}/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__BAKEFILES__}/remote.bakefile")
	EXPECTED
)"
