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
  source "${__BAKE_SRC_PATH__}/trace.sh"
  source "${__BAKE_SRC_PATH__}/annotations.sh"
  source "${__BAKE_SRC_PATH__}/recipe.sh"
  source "${__BAKE_SRC_PATH__}/recipes.sh"

  source "${__BAKE_SRC_PATH__}/cli.sh"

  ##############################################################################

  bake() {
    # Because this function can be used to invoke recipes from within other
    # recipe invocation, we need to reset the shell options to default before
    # starting the new invocations. Then, we will have to restore the options
    # set by the invoking recipe, to let it continue its execution with the
    # expected shell options.
    #
    # Note: we use `{ ... } 2>/dev/null` in case the invoking recipe did
    # `set -x`.
    {
      local shopts="$-"

      bake::utils::shell::reset_options
    } 2>/dev/null

    bake::trace::increase_invocation_level

    bake::recipes::invoke "$@"

    # TODO: Decide how to clarify when nestedly invoked recipes are done.
    # if ! bake::options::quiet; then
    #   bake::display::info "$(bake::trace::invocation_prefix)$*" "Done!"
    # fi

    bake::trace::decrease_invocation_level
    bake::utils::shell::restore_options "${shopts}"
  }

  bake::abort() {
    bake::display::error "${__BAKE_CONSTANT_COMMAND_NAME__}" "$1"

    exit 1
  }

  ##############################################################################

  local positional_arguments

  bake::cli::parse_options positional_arguments "$@"
  bake::load_bakefile
  bake::load_recipes

  if bake::options::version; then
    bake::display::info "${__BAKE_CONSTANT_COMMAND_NAME__}" "${__BAKE_CONSTANT_VERSION__}"

    exit 0
  elif bake::options::help; then
    bake::cli::print_help

    [[ $(bake::recipes::count) -gt 0 ]] && printf "\n"

    bake::recipes::print_list

    exit 0
  elif bake::options::list; then
    bake::recipes::print_list

    exit 0
  elif [[ $(bake::recipes::count) -eq 0 ]]; then
    bake::abort "No recipes!"
  fi

  bake::recipes::invoke ${positional_arguments+"${positional_arguments[@]}"}
}

bake::main "$@"
