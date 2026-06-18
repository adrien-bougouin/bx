#!/bin/bash

bake::main() (
  set -euo pipefail

  __BAKE_BAKEFILE__=

  local SRC_DIR

  local COMMAND_NAME="bake"
  local TEXT_INDENT="    "

  SRC_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  readonly SRC_DIR

  readonly COMMAND_NAME
  readonly TEXT_INDENT

  source "${SRC_DIR}/string.sh"
  source "${SRC_DIR}/term.sh"

  source "${SRC_DIR}/progress.sh"
  source "${SRC_DIR}/cli.sh"
  source "${SRC_DIR}/recipe.sh"

  bake::print_help() {
    bake::cli::print_help "${COMMAND_NAME}" "${TEXT_INDENT}"

    [[ $(bake::recipe_count) -gt 0 ]] && printf "\n"

    bake::print_recipe_list "${TEXT_INDENT}"
  }

  bake::abort() {
    bake::term::stderr "%s %s!\n" \
      "${__BAKE_TERM_BOLD__}${COMMAND_NAME}:${__BAKE_TERM_RESET__}" \
      "$(bake::string::capitalize "${1}")"

    exit 1
  }

  # Parse CLI options ##########################################################

  bake::cli::init "$@"

  # Shift bake option arguments to point to the first recipe to call
  for ((i = 1; i <= __BAKE_ARGPARSE_SHIFT_COUNT__; i++)); do
    shift
  done

  __BAKE_BAKEFILE__="${__BAKE_OPTION_BAKEFILE__:-"$(pwd)/Bakefile"}"
  readonly __BAKE_BAKEFILE__

  if [[ ! -f ${__BAKE_BAKEFILE__} ]] && [[ ${__BAKE_OPTION_HELP__} != true ]]; then
    bake::abort "no recipes"
  fi

  ##############################################################################

  bake::load_recipes "${__BAKE_BAKEFILE__}"

  if [[ ${__BAKE_OPTION_HELP__} == true ]]; then
    bake::print_help
    exit 0
  fi

  # TODO: bake::recipes::exec
  if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
      # shellcheck disable=SC2086
      bake::recipe::exec $1

      shift
    done
  else
    if [[ -n $(bake::recipe::default) ]]; then
      # shellcheck disable=SC2086,SC2046
      bake::recipe::exec $(bake::recipe::default)
    else
      bake::abort "nothing to do"
    fi
  fi
)

bake::main "$@"
