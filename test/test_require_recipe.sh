#!/bin/bash

skip assert_output "bake -q -f ./bakefiles/require.bakefile one-dependent" "$(
	cat <<-EXPECTED
		- required
		- dependent
	EXPECTED
)"

skip assert_output "bake -q -f ./bakefiles/require.bakefile one-dependent--subprocess" "$(
	cat <<-EXPECTED
		- required
		- dependent
	EXPECTED
)"

skip assert_output "bake -q -f ./bakefiles/require.bakefile multi-dependent" "$(
	cat <<-EXPECTED
		- required
		- required
		- required
		- dependent
	EXPECTED
)"

skip assert_output "bake -q -f ./bakefiles/require.bakefile multi-dependent--subprocess" "$(
	cat <<-EXPECTED
		- required
		- required
		- required
		- dependent
	EXPECTED
)"

skip assert_output "bake -q -f ./bakefiles/require.bakefile multi-dependent--with-args" "$(
	cat <<-EXPECTED
		- required #1
		- required #2
		- required #3
		- dependent
	EXPECTED
)"
