#!/bin/bash

assert_stderr "TERM= bake -- -h" "$(
	cat <<-EXPECTED
		-h
	EXPECTED
)"
