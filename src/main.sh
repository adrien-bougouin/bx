#!/bin/bash

_bake::main() {
  set -euo pipefail

  local __BAKE_WORKING_DIRECTORY__
  local __BAKE_SRC_PATH__

  __BAKE_WORKING_DIRECTORY__="$(pwd)"
  __BAKE_SRC_PATH__="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

  readonly __BAKE_WORKING_DIRECTORY__
  readonly __BAKE_SRC_PATH__

  source "${__BAKE_SRC_PATH__}/utils.sh"

  source "${__BAKE_SRC_PATH__}/constants.sh"
  source "${__BAKE_SRC_PATH__}/display.sh"
  source "${__BAKE_SRC_PATH__}/options.sh"
  source "${__BAKE_SRC_PATH__}/bakefile.sh"
  source "${__BAKE_SRC_PATH__}/annotation_parsing_stack.sh"
  source "${__BAKE_SRC_PATH__}/invocation_stack.sh"
  source "${__BAKE_SRC_PATH__}/annotations.sh"
  source "${__BAKE_SRC_PATH__}/recipe.sh"
  source "${__BAKE_SRC_PATH__}/recipes.sh"

  source "${__BAKE_SRC_PATH__}/cli.sh"

  ##############################################################################

  # Wrap `set` to ensure xtrace does not get enabled when Bake executes in quiet
  # mode.
  set() {
    {
      builtin set "$@"
      _bake::options::quiet && builtin set +x || true
    } 2>/dev/null
  }

  bake::invoke() {
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

      _bake::utils::shell::reset_options
    } 2>/dev/null

    _bake::recipes::invoke "$@"

    _bake::utils::shell::restore_options "${shopts}"
  }

  _bake::abort() {
    _bake::display::error "{{bold}}${__BAKE_CONSTANT_COMMAND_NAME__}:{{normal}} $1"

    exit 1
  }

  ##############################################################################

  local positional_arguments

  _bake::cli::parse_options positional_arguments "$@"
  _bake::load_bakefile
  _bake::load_recipes --ignore '^(_?bake::|_?bake$|set$)'

  if _bake::options::version; then
    _bake::display::info "{{bold}}${__BAKE_CONSTANT_COMMAND_NAME__}:{{normal}} ${__BAKE_CONSTANT_VERSION__}"

    exit 0
  elif _bake::options::help; then
    _bake::cli::print_help

    [[ $(_bake::recipes::count) -gt 0 ]] && printf "\n"

    _bake::recipes::print_list

    exit 0
  elif _bake::options::list; then
    _bake::recipes::print_list

    exit 0
  elif [[ $(_bake::recipes::count) -eq 0 ]]; then
    _bake::abort "No recipes!"
  fi

  if [[ -n ${BASH_XTRACEFD-} ]] && [[ ${BASH_XTRACEFD} != "2" ]] && ! _bake::options::quiet; then
    BASH_XTRACEFD=2

    _bake::display::warning "{{bold}}${__BAKE_CONSTANT_COMMAND_NAME__}:{{normal}} BASH_XTRACEFD is not supported, resetting it to stderr."
  fi

  _bake::recipes::invoke ${positional_arguments+"${positional_arguments[@]}"}
}

_bake::main "$@"
