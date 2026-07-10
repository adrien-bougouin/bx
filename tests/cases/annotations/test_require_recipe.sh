#!/bin/bash

assert_stdout "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/annotations/require_recipe.bakefile' one-dependent" "$(
	cat <<-EXPECTED
		require
		- required
		one-dependent
		- dependent
	EXPECTED
)"

assert_stdout "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/annotations/require_recipe.bakefile' one-dependent--subprocess" "$(
	cat <<-EXPECTED
		require
		- required
		one-dependent--subprocess
		- dependent
	EXPECTED
)"

assert_stderr "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/annotations/require_recipe.bakefile' one-dependent--missing" "$(
	cat <<-EXPECTED
		bake: No recipe 'missing'!
	EXPECTED
)"

assert_stdout "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/annotations/require_recipe.bakefile' multi-dependent" "$(
	cat <<-EXPECTED
		require
		- required
		require
		- required
		require
		- required
		multi-dependent
		- dependent
	EXPECTED
)"

assert_stdout "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/annotations/require_recipe.bakefile' multi-dependent--subprocess" "$(
	cat <<-EXPECTED
		require
		- required
		require
		- required
		require
		- required
		multi-dependent--subprocess
		- dependent
	EXPECTED
)"

assert_stderr "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/annotations/require_recipe.bakefile' multi-dependent--missing > /dev/null" "$(
	cat <<-EXPECTED
		bake: No recipe 'missing'!
	EXPECTED
)"

assert_stdout "TERM= bake -f '${__TEST_BAKEFILES_PATH__}/annotations/require_recipe.bakefile' multi-dependent--with-args" "$(
	cat <<-EXPECTED
		require--with-args 1
		- required #1
		require--with-args 2
		- required #2
		require--with-args 3
		- required #3
		multi-dependent--with-args
		- dependent
	EXPECTED
)"
