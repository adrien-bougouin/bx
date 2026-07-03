#!/bin/bash

bake::main() {
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
  source "${__BAKE_SRC_PATH__}/state.sh"
  source "${__BAKE_SRC_PATH__}/bakefile.sh"
  source "${__BAKE_SRC_PATH__}/annotations.sh"
  source "${__BAKE_SRC_PATH__}/recipe.sh"
  source "${__BAKE_SRC_PATH__}/recipes.sh"

  source "${__BAKE_SRC_PATH__}/cli.sh"

  ##############################################################################

  bake::abort() {
    bake::term::stderrf "%s %s!\n" \
      "$(bake::term::style::bold)${__BAKE_CONSTANT_COMMAND_NAME__}:$(bake::term::style::clear)" \
      "$(bake::utils::string::capitalize "${1}")"

    exit 1
  }

  # Parse CLI options ##########################################################

  bake::_cli::_parse_options "$@"

  local cli_options_offset
  cli_options_offset="$(bake::_cli::_options_offset)"

  # Shift bake option arguments to point to the first recipe to call
  local i_offset
  for ((i_offset = 1; i_offset <= cli_options_offset; i_offset++)); do
    shift
  done

  # TODO:
  #   - Test: no bakefile - no help option - show 'no recipes'
  if [[ ! -f $(bake::bakefile) ]] && ! bake::options::help; then
    bake::abort "no recipes"
  fi

  ##############################################################################

  bake::recipes::_load "$(bake::bakefile)"

  # Show help ##################################################################

  if bake::options::help; then
    bake::_cli::print_help

    [[ $(bake::recipes::_count) -gt 0 ]] && printf "\n"

    bake::recipes::print_list

    exit 0
  fi

  ##############################################################################

  bake::recipes::execute "$@"
}

bake::main "$@"
