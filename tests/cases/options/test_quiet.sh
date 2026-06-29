#!/bin/bash

TPUT_BOLD=""
TPUT_RESET=""

# BASH unset ${TERM} value is 'dumb'!
if [[ ${TERM:-dumb} != "dumb" ]]; then
	TPUT_BOLD="$(tput bold)"
	TPUT_RESET="$(tput sgr0)"
fi

assert_stdout "bake -f '${__TEST_BAKEFILES_PATH__}/options/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		${TPUT_BOLD}do-something${TPUT_RESET}
		Done!
	EXPECTED
)"

assert_stdout "bake -s -f '${__TEST_BAKEFILES_PATH__}/options/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_stdout "bake --silent -f '${__TEST_BAKEFILES_PATH__}/options/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_stdout "bake -q -f '${__TEST_BAKEFILES_PATH__}/options/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_stdout "bake --quiet -f '${__TEST_BAKEFILES_PATH__}/options/quiet.bakefile' do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"
