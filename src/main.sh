#!/bin/bash

bake::main() (
  set -euo pipefail

  local __BAKE_WORKING_DIRECTORY__
  local __BAKE_SRC_PATH__

  __BAKE_WORKING_DIRECTORY__="$(pwd)"
  __BAKE_SRC_PATH__="$(realpath "${BASH_SOURCE[0]%/*}")"

  readonly __BAKE_WORKING_DIRECTORY__
  readonly __BAKE_SRC_PATH__

  source "${__BAKE_SRC_PATH__}/string.sh"
  source "${__BAKE_SRC_PATH__}/term.sh"

  source "${__BAKE_SRC_PATH__}/options.sh"
  source "${__BAKE_SRC_PATH__}/progress.sh"
  source "${__BAKE_SRC_PATH__}/bakefile.sh"
  source "${__BAKE_SRC_PATH__}/recipe.sh"

  source "${__BAKE_SRC_PATH__}/cli.sh"

  ##############################################################################

  local COMMAND_NAME="bake"
  local TEXT_INDENT="    "

  readonly COMMAND_NAME
  readonly TEXT_INDENT

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

  # TODO:
  #   - Test: no bakefile - help option - show help
  #   - Test: no bakefile - no help option - show 'no recipes'
  if [[ ! -f $(bake::bakefile) ]] && ! bake::options::help; then
    bake::abort "no recipes"
  fi

  ##############################################################################

  bake::load_recipes "$(bake::bakefile)"

  if bake::options::help; then
    bake::print_help
    exit 0
  fi

  bake::execute_recipes "$@"
)

bake::main "$@"
