#!/bin/bash

assert_output "bake -q -f '${__BAKEFILES__}/require.bakefile' one-dependent" "$(
	cat <<-EXPECTED
		- required
		- dependent
	EXPECTED
)"

assert_output "bake -q -f '${__BAKEFILES__}/require.bakefile' one-dependent--subprocess" "$(
	cat <<-EXPECTED
		- required
		- dependent
	EXPECTED
)"

assert_output "bake -q -f '${__BAKEFILES__}/require.bakefile' multi-dependent" "$(
	cat <<-EXPECTED
		- required
		- required
		- required
		- dependent
	EXPECTED
)"

assert_output "bake -q -f '${__BAKEFILES__}/require.bakefile' multi-dependent--subprocess" "$(
	cat <<-EXPECTED
		- required
		- required
		- required
		- dependent
	EXPECTED
)"

assert_output "bake -q -f '${__BAKEFILES__}/require.bakefile' multi-dependent--with-args" "$(
	cat <<-EXPECTED
		- required #1
		- required #2
		- required #3
		- dependent
	EXPECTED
)"

assert_output "TERM= bake -q -f '${__BAKEFILES__}/require__circular.bakefile' circular-dependent" "$(
	cat <<-EXPECTED
		bake: Circular requirement for recipe 'circular-dependent'!
	EXPECTED
)"
