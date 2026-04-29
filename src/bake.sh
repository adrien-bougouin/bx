#!/bin/bash

set -euo pipefail

readonly __BAKE_COMMAND__=bake

__BAKE_SRC_DIR__="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
readonly __BAKE_SRC_DIR__

__BAKE_BIN_DIR__="$(dirname "${__BAKE_SRC_DIR__}")/bin"
readonly __BAKE_BIN_DIR__

__BAKE__="${__BAKE_BIN_DIR__}/${__BAKE_COMMAND__}"
readonly __BAKE__

readonly __BAKE_INDENT__="    "

bake::abort() {
  local capitalized_error

  capitalized_error="$(printf "%s" "${1:0:1}" | tr '[:lower:]' '[:upper:]')${1:1}"

  printf "%s%s:%s %s!\n" \
    "${__BAKE_TERM_BOLD__}" \
    "${__BAKE_COMMAND__}" \
    "${__BAKE_TERM_RESET__}" \
    "${capitalized_error}"

  exit 1
}

################################################################################

source "${__BAKE_SRC_DIR__}/term.sh"
source "${__BAKE_SRC_DIR__}/cli.sh"
source "${__BAKE_SRC_DIR__}/engine.sh"

# argparse #####################################################################

bake::cli::argparse "$@"

# Shift bake option arguments to point to the first recipe to call
for ((i = 1; i <= __BAKE_ARGPARSE_SHIFT_COUNT__; i++)); do
  shift
done

__BAKEFILE__="${__BAKE_OPTION_BAKEFILE__:-"$(pwd)/Bakefile"}"
readonly __BAKEFILE__

if [[ ! -f ${__BAKEFILE__} ]] && [[ ${__BAKE_OPTION_HELP__} != true ]]; then
  bake::abort "no recipes"
fi

# load #########################################################################

[[ -f ${__BAKEFILE__} ]] && source "${__BAKEFILE__}"

bake::engine::load

if [[ ${__BAKE_OPTION_HELP__} == true ]]; then
  bake::cli::help

  [[ ${#__BAKE_RECIPES__[@]} -gt 0 ]] && printf "\n"

  bake::engine::list

  exit 0
fi

# exec #########################################################################

if [[ $# -gt 0 ]]; then
  while [[ $# -gt 0 ]]; do
    # shellcheck disable=SC2086
    bake::engine::exec $1

    shift
  done
else
  if [[ -n ${__BAKE_DEFAULT__} ]]; then
    # shellcheck disable=SC2086
    bake::engine::exec ${__BAKE_DEFAULT__}
  else
    bake::abort "nothing to do"
  fi
fi
