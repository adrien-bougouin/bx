#!/bin/bash

set +ex -o pipefail

PASS_COUNT=0
FAIL_COUNT=0

TPUT_RESET_ARGS=(sgr0)
TPUT_RED_FG_ARGS=(setaf 1)
TPUT_GREEN_FG_ARGS=(setaf 2)

readonly TPUT_RESET_ARGS
readonly TPUT_RED_FG_ARGS
readonly TPUT_GREEN_FG_ARGS

assert_output() {
  local command
  local expected
  local actual

  command="$1"
  expected="$2"
  actual="$(eval "${command}")"

  if [[ ${expected} != "${actual}" ]]; then
    printf "%s[FAILED]%s %s\n" \
      "$(tput "${TPUT_RED_FG_ARGS[@]}")" \
      "$(tput "${TPUT_RESET_ARGS[@]}")" \
      "${command}"
    printf "    Expected: %q\n" "${expected}"
    printf "    Actual:   %q\n" "${actual}"

    FAIL_COUNT=$((FAIL_COUNT + 1))
  else
    printf "%s[PASSED]%s %s\n" \
      "$(tput "${TPUT_GREEN_FG_ARGS[@]}")" \
      "$(tput "${TPUT_RESET_ARGS[@]}")" \
      "${command}"

    PASS_COUNT=$((PASS_COUNT + 1))
  fi
}

while [[ $# -gt 0 ]]; do
  printf "===== %s\n\n" "$(realpath "$1")"

  source "$1"
  shift

  [[ $# -gt 0 ]] && printf "\n"
done

printf "\n===== %s%d PASSED%s" \
  "$(tput "${TPUT_GREEN_FG_ARGS[@]}")" \
  "${PASS_COUNT}" \
  "$(tput "${TPUT_RESET_ARGS[@]}")"

printf " - %s%d FAILED%s\n" \
  "$(tput "${TPUT_RED_FG_ARGS[@]}")" \
  "${FAIL_COUNT}" \
  "$(tput "${TPUT_RESET_ARGS[@]}")"

exit "${FAIL_COUNT}"
