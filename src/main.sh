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
  source "${__BAKE_SRC_PATH__}/display.sh"
  source "${__BAKE_SRC_PATH__}/options.sh"
  source "${__BAKE_SRC_PATH__}/state.sh"
  source "${__BAKE_SRC_PATH__}/bakefile.sh"
  source "${__BAKE_SRC_PATH__}/annotations.sh"
  source "${__BAKE_SRC_PATH__}/recipe.sh"
  source "${__BAKE_SRC_PATH__}/recipes.sh"

  source "${__BAKE_SRC_PATH__}/cli.sh"

  ##############################################################################

  bake::abort() {
    bake::display::error "${__BAKE_CONSTANT_COMMAND_NAME__}" "$1"

    exit 1
  }

  ##############################################################################

  local positional_arguments

  bake::_cli::_parse_options positional_arguments "$@"
  bake::recipes::_load "$(bake::bakefile)"

  if bake::options::version; then
    bake::display::info "${__BAKE_CONSTANT_COMMAND_NAME__}" "${__BAKE_CONSTANT_VERSION__}"

    exit 0
  elif bake::options::help; then
    bake::_cli::print_help

    [[ $(bake::recipes::_count) -gt 0 ]] && printf "\n"

    bake::recipes::print_list

    exit 0
  elif bake::options::list; then
    bake::recipes::print_list

    exit 0
  elif [[ $(bake::recipes::_count) -eq 0 ]]; then
    bake::abort "No recipes!"
  fi

  bake::recipes::execute ${positional_arguments+"${positional_arguments[@]}"}
}

bake::main "$@"
