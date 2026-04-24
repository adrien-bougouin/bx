#!/bin/bash

assert_output "bake -f ./bakefiles/quiet.bakefile do-something" "$(
	cat <<-EXPECTED
		$(tput bold)do-something$(tput sgr0)
		Done!
	EXPECTED
)"

assert_output "bake -s -f ./bakefiles/quiet.bakefile do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_output "bake --silent -f ./bakefiles/quiet.bakefile do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_output "bake -q -f ./bakefiles/quiet.bakefile do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"

assert_output "bake --quiet -f ./bakefiles/quiet.bakefile do-something" "$(
	cat <<-EXPECTED
		Done!
	EXPECTED
)"
