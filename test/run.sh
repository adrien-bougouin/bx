#!/bin/bash

set +ex -uo pipefail

TEST_DIRECTORY="$(dirname "${BASH_SOURCE[0]}")"
readonly TEST_DIRECTORY

__BAKEFILES__="${TEST_DIRECTORY}/bakefiles"
readonly __BAKEFILES__

source "${TEST_DIRECTORY}/../src/term.sh"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

skip() {
  local command="$2"

  printf "%s[SKIPPED]%s %s\n" \
    "${__BAKE_TERM_YELLOW_FG__}" \
    "${__BAKE_TERM_RESET__}" \
    "${command}"

  SKIP_COUNT=$((SKIP_COUNT + 1))
}

assert_output() {
  local command
  local expected
  local actual

  command="$1"
  expected="$2"
  actual="$(eval "${command}")"

  if [[ ${expected} != "${actual}" ]]; then
    printf "%s[FAILED]%s  %s\n" \
      "${__BAKE_TERM_RED_FG__}" \
      "${__BAKE_TERM_RESET__}" \
      "${command}"
    printf "    Expected: %q\n" "${expected}"
    printf "    Actual:   %q\n" "${actual}"

    FAIL_COUNT=$((FAIL_COUNT + 1))
  else
    printf "%s[PASSED]%s  %s\n" \
      "${__BAKE_TERM_GREEN_FG__}" \
      "${__BAKE_TERM_RESET__}" \
      "${command}"

    PASS_COUNT=$((PASS_COUNT + 1))
  fi
}

while [[ $# -gt 0 ]]; do
  printf "========= %s\n\n" "$1"

  source "$1"
  shift

  [[ $# -gt 0 ]] && printf "\n"
done

printf "\n========= %s%d PASSED%s" \
  "${__BAKE_TERM_GREEN_FG__}" \
  "${PASS_COUNT}" \
  "${__BAKE_TERM_RESET__}"

printf " - %s%d SKIPPED%s" \
  "${__BAKE_TERM_YELLOW_FG__}" \
  "${SKIP_COUNT}" \
  "${__BAKE_TERM_RESET__}"

printf " - %s%d FAILED%s" \
  "${__BAKE_TERM_RED_FG__}" \
  "${FAIL_COUNT}" \
  "${__BAKE_TERM_RESET__}"

printf "\n"

exit "${FAIL_COUNT}"
