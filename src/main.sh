#!/bin/bash

bake::main() (
  set -euo pipefail

  local __BAKE_SRC_DIR__

  __BAKE_SRC_DIR__="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
  readonly __BAKE_SRC_DIR__

  source "${__BAKE_SRC_DIR__}/string.sh"
  source "${__BAKE_SRC_DIR__}/term.sh"

  source "${__BAKE_SRC_DIR__}/progress.sh"
  source "${__BAKE_SRC_DIR__}/cli.sh"
  source "${__BAKE_SRC_DIR__}/recipe.sh"

  ##############################################################################

  __BAKE_BAKEFILE__=

  local COMMAND_NAME="bake"
  local TEXT_INDENT="    "

  readonly COMMAND_NAME
  readonly TEXT_INDENT

  bake::print_help() {
    bake::cli::print_help "${COMMAND_NAME}" "${TEXT_INDENT}"

    [[ $(bake::get_recipe_count) -gt 0 ]] && printf "\n"

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
    if [[ -n $(bake::get_default_recipe) ]]; then
      # shellcheck disable=SC2086,SC2046
      bake::recipe::exec $(bake::get_default_recipe)
    else
      bake::abort "nothing to do"
    fi
  fi
)

bake::main "$@"
