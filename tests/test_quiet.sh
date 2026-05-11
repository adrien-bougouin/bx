#!/bin/bash

TPUT_BOLD=""
TPUT_RESET=""

# BASH unset ${TERM} value is 'dumb'!
if [[ ${TERM:-dumb} != "dumb" ]]; then
	TPUT_BOLD="$(tput bold)"
	TPUT_RESET="$(tput sgr0)"
fi

assert_stdout "bake -f '${__BAKEFILES__}/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		${TPUT_BOLD}do-something${TPUT_RESET}
		Done!
	EXPECTED
)"

assert_stdout "bake -s -f '${__BAKEFILES__}/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_stdout "bake --silent -f '${__BAKEFILES__}/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_stdout "bake -q -f '${__BAKEFILES__}/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_stdout "bake --quiet -f '${__BAKEFILES__}/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"
