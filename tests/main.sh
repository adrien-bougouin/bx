#!/bin/bash

bake::tests::main() (
  set +ex -uo pipefail

  local __TEST_BAKEFILES__

  local SRC_DIR
  local TESTS_DIR

  TESTS_DIR="$(dirname "${BASH_SOURCE[0]}")"
  SRC_DIR="${TESTS_DIR}/../src"

  readonly SRC_DIR
  readonly TESTS_DIR

  __TEST_BAKEFILES__="${TESTS_DIR}/bakefiles"
  readonly __TEST_BAKEFILES__

  source "${SRC_DIR}/term.sh"

  local pass_count=0
  local fail_count=0
  local skip_count=0

  skip() {
    local command="$2"

    printf "%s\n" "$(bake::term::style::yellow_fg)[FAILED]$(bake::term::style::clear) ${command}"

    skip_count=$((skip_count + 1))
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
      printf "%s\n" "$(bake::term::style::red_fg)[FAILED]$(bake::term::style::clear)  ${command}"
      printf "    Expected [stderr]: %q\n" ""
      printf "    Actual   [stderr]: %q\n" "${actual_stderr}"

      fail_count=$((fail_count + 1))
    elif [[ ${expected} != "${actual_stdout}" ]]; then
      printf "%s\n" "$(bake::term::style::red_fg)[FAILED]$(bake::term::style::clear)  ${command}"
      printf "    Expected [stdout]: %q\n" "${expected}"
      printf "    Actual   [stdout]: %q\n" "${actual_stdout}"

      fail_count=$((fail_count + 1))
    else
      printf "%s\n" "$(bake::term::style::green_fg)[PASSED]$(bake::term::style::clear)  ${command}"

      pass_count=$((pass_count + 1))
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
      printf "%s\n" "$(bake::term::style::red_fg)[FAILED]$(bake::term::style::clear)  ${command}"
      printf "    Expected [stdout]: %q\n" ""
      printf "    Actual   [stdout]: %q\n" "${actual_stdout}"

      fail_count=$((fail_count + 1))
    elif [[ ${expected} != "${actual_stderr}" ]]; then
      printf "%s\n" "$(bake::term::style::red_fg)[FAILED]$(bake::term::style::clear)  ${command}"
      printf "    Expected [stderr]: %q\n" "${expected}"
      printf "    Actual   [stderr]: %q\n" "${actual_stderr}"

      fail_count=$((fail_count + 1))
    else
      printf "%s\n" "$(bake::term::style::green_fg)[PASSED]$(bake::term::style::clear)  ${command}"

      pass_count=$((pass_count + 1))
    fi
  }

  while [[ $# -gt 0 ]]; do
    printf "========= %s\n\n" "$1"

    source "$1"
    shift

    [[ $# -gt 0 ]] && printf "\n"
  done

  printf "\n========= %s" "$(bake::term::style::green_fg)${pass_count} PASSED$(bake::term::style::clear)"
  printf " - %s" "$(bake::term::style::yellow_fg)${skip_count} SKIPPED$(bake::term::style::clear)"
  printf " - %s\n" "$(bake::term::style::red_fg)${fail_count} FAILED$(bake::term::style::clear)"

  exit "${fail_count}"
)

if [[ $# -gt 0 ]]; then
  bake::tests::main "$@"
fi
