#!/bin/bash

set +ex -uo pipefail

TEST_DIRECTORY="$(dirname "${BASH_SOURCE[0]}")"
__TEST_BAKEFILES__="${TEST_DIRECTORY}/bakefiles"

readonly TEST_DIRECTORY
readonly __TEST_BAKEFILES__

source "${TEST_DIRECTORY}/../src/term.sh"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

skip() {
  local command="$2"

  printf "%s\n" "${__BAKE_TERM_YELLOW_FG__}[FAILED]${__BAKE_TERM_RESET__} ${command}"

  SKIP_COUNT=$((SKIP_COUNT + 1))
}

assert_stdout() {
  local command
  local expected
  local actual_stdout
  local actual_stderr

  command="$1"
  expected="$2"

  {
    IFS=$'\n' read -r -d '' actual_stderr
    IFS=$'\n' read -r -d '' actual_stdout
  } < <((printf '\0%s\0' "$(eval "${command}")" 1>&2) 2>&1)

  if [[ ${actual_stderr} != "" ]]; then
    printf "%s\n" "${__BAKE_TERM_RED_FG__}[FAILED]${__BAKE_TERM_RESET__}  ${command}"
    printf "    Expected [stderr]: %q\n" ""
    printf "    Actual   [stderr]: %q\n" "${actual_stderr}"

    FAIL_COUNT=$((FAIL_COUNT + 1))
  elif [[ ${expected} != "${actual_stdout}" ]]; then
    printf "%s\n" "${__BAKE_TERM_RED_FG__}[FAILED]${__BAKE_TERM_RESET__}  ${command}"
    printf "    Expected [stdout]: %q\n" "${expected}"
    printf "    Actual   [stdout]: %q\n" "${actual_stdout}"

    FAIL_COUNT=$((FAIL_COUNT + 1))
  else
    printf "%s\n" "${__BAKE_TERM_GREEN_FG__}[PASSED]${__BAKE_TERM_RESET__}  ${command}"

    PASS_COUNT=$((PASS_COUNT + 1))
  fi
}

assert_stderr() {
  local command
  local expected
  local actual_stdout
  local actual_stderr

  command="$1"
  expected="$2"

  {
    IFS=$'\n' read -r -d '' actual_stderr
    IFS=$'\n' read -r -d '' actual_stdout
  } < <((printf '\0%s\0' "$(eval "${command}")" 1>&2) 2>&1)

  if [[ ${actual_stdout} != "" ]]; then
    printf "%s\n" "${__BAKE_TERM_RED_FG__}[FAILED]${__BAKE_TERM_RESET__}  ${command}"
    printf "    Expected [stdout]: %q\n" ""
    printf "    Actual   [stdout]: %q\n" "${actual_stdout}"

    FAIL_COUNT=$((FAIL_COUNT + 1))
  elif [[ ${expected} != "${actual_stderr}" ]]; then
    printf "%s\n" "${__BAKE_TERM_RED_FG__}[FAILED]${__BAKE_TERM_RESET__}  ${command}"
    printf "    Expected [stderr]: %q\n" "${expected}"
    printf "    Actual   [stderr]: %q\n" "${actual_stderr}"

    FAIL_COUNT=$((FAIL_COUNT + 1))
  else
    printf "%s\n" "${__BAKE_TERM_GREEN_FG__}[PASSED]${__BAKE_TERM_RESET__}  ${command}"

    PASS_COUNT=$((PASS_COUNT + 1))
  fi
}

while [[ $# -gt 0 ]]; do
  printf "========= %s\n\n" "$1"

  source "$1"
  shift

  [[ $# -gt 0 ]] && printf "\n"
done

printf "\n========= %s" "${__BAKE_TERM_GREEN_FG__}${PASS_COUNT} PASSED${__BAKE_TERM_RESET__}"
printf " - %s" "${__BAKE_TERM_YELLOW_FG__}${SKIP_COUNT} SKIPPED${__BAKE_TERM_RESET__}"
printf " - %s\n" "${__BAKE_TERM_RED_FG__}${FAIL_COUNT} FAILED${__BAKE_TERM_RESET__}"

exit "${FAIL_COUNT}"
