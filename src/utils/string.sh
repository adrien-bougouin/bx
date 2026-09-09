#!/bin/bash
#
# String manipulation utilities for the bx tool.

################################################################################
# Trim a pattern from both the start and end of a string.
#
# Repeatedly strips the given pattern from the beginning and end of the input
# string until no further occurrences remain.
#
# Arguments:
#   input   - The string to trim.
#   pattern - The pattern to strip from both ends of the string.
#
# Outputs:
#   Writes the trimmed string to stdout.
################################################################################
_bx::utils::string::trim() {
  local input="$1"
  local pattern="$2"

  local previous_trim=""
  local last_trim="${input}"

  until [[ ${previous_trim} == "${last_trim}" ]]; do
    previous_trim="${last_trim}"

    last_trim="${last_trim#"${pattern}"}"
    last_trim="${last_trim%"${pattern}"}"
  done

  printf "%s" "${last_trim}"
}
