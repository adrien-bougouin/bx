#!/bin/bash

bake::main() (
  set -euo pipefail

  local __BAKE_WORKING_DIRECTORY__
  local __BAKE_SRC_PATH__

  __BAKE_WORKING_DIRECTORY__="$(pwd)"
  __BAKE_SRC_PATH__="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

  readonly __BAKE_WORKING_DIRECTORY__
  readonly __BAKE_SRC_PATH__

  source "${__BAKE_SRC_PATH__}/utils.sh"
  source "${__BAKE_SRC_PATH__}/term.sh"

  source "${__BAKE_SRC_PATH__}/constants.sh"
  source "${__BAKE_SRC_PATH__}/options.sh"
  source "${__BAKE_SRC_PATH__}/progress.sh"
  source "${__BAKE_SRC_PATH__}/bakefile.sh"
  source "${__BAKE_SRC_PATH__}/annotations.sh"
  source "${__BAKE_SRC_PATH__}/recipe.sh"
  source "${__BAKE_SRC_PATH__}/recipes.sh"

  source "${__BAKE_SRC_PATH__}/cli.sh"

  ##############################################################################

  bake::abort() {
    bake::term::stderr "%s %s!\n" \
      "${__BAKE_TERM_BOLD__}${__BAKE_CONSTANT_COMMAND_NAME__}:${__BAKE_TERM_RESET__}" \
      "$(bake::utils::string::capitalize "${1}")"

    exit 1
  }

  # Parse CLI options ##########################################################

  bake::cli::parse_options "$@"

  # Shift bake option arguments to point to the first recipe to call
  for ((i = 1; i <= $(bake::cli::options_offset); i++)); do
    shift
  done

  # TODO:
  #   - Test: no bakefile - help option - show help
  #   - Test: no bakefile - no help option - show 'no recipes'
  if [[ ! -f $(bake::bakefile) ]] && ! bake::options::help; then
    bake::abort "no recipes"
  fi

  ##############################################################################

  bake::recipes::load "$(bake::bakefile)"

  # Show help ##################################################################

  if bake::options::help; then
    bake::cli::print_help

    [[ $(bake::recipes::count) -gt 0 ]] && printf "\n"

    bake::recipes::print_list

    exit 0
  fi

  ##############################################################################

  bake::recipes::execute "$@"
)

bake::main "$@"
