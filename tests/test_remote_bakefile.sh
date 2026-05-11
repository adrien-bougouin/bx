#!/bin/bash

assert_stdout "bake -q -f '${__BAKEFILES__}/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__BAKEFILES__}/remote.bakefile")
	EXPECTED
)"

assert_stdout "bake -q --file '${__BAKEFILES__}/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__BAKEFILES__}/remote.bakefile")
	EXPECTED
)"

assert_stdout "bake -q --bakefile '${__BAKEFILES__}/remote.bakefile' which-bakefile" "$(
	cat <<-EXPECTED
		$(realpath "${__BAKEFILES__}/remote.bakefile")
	EXPECTED
)"
