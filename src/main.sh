#!/bin/bash

_bx::main() {
  set -euo pipefail

  local __BX_WORKING_DIRECTORY__
  local __BX_SRC_PATH__

  __BX_WORKING_DIRECTORY__="$(pwd)"
  __BX_SRC_PATH__="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

  readonly __BX_WORKING_DIRECTORY__
  readonly __BX_SRC_PATH__

  source "${__BX_SRC_PATH__}/utils.sh"

  source "${__BX_SRC_PATH__}/constants.sh"
  source "${__BX_SRC_PATH__}/display.sh"
  source "${__BX_SRC_PATH__}/options.sh"
  # TODO: revert to "bashfile.sh" when the file is renamed.
  source "${__BX_SRC_PATH__}/bakefile.sh"
  source "${__BX_SRC_PATH__}/annotation_parsing_stack.sh"
  source "${__BX_SRC_PATH__}/invocation_stack.sh"
  source "${__BX_SRC_PATH__}/annotations.sh"
  source "${__BX_SRC_PATH__}/recipe.sh"
  source "${__BX_SRC_PATH__}/recipes.sh"

  source "${__BX_SRC_PATH__}/overrides.sh"
  source "${__BX_SRC_PATH__}/dsl.sh"
  source "${__BX_SRC_PATH__}/cli.sh"

  ##############################################################################

  _bx::abort() {
    _bx::display::error "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} $1"

    exit 1
  }

  ##############################################################################

  local positional_arguments

  _bx::cli::parse_options positional_arguments "$@"
  _bx::load_bashfile
  _bx::load_recipes --ignore '^(_|_?bx::|_?bx$|set$)'

  if _bx::options::version; then
    _bx::display::info "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} ${__BX_CONSTANT_VERSION__}"

    exit 0
  elif _bx::options::help; then
    _bx::cli::print_help

    [[ $(_bx::recipes::count) -gt 0 ]] && printf "\n"

    _bx::recipes::print_list

    exit 0
  elif _bx::options::list; then
    _bx::recipes::print_list

    exit 0
  elif [[ $(_bx::recipes::count) -eq 0 ]]; then
    _bx::abort "No recipes!"
  fi

  if [[ -n ${BASH_XTRACEFD-} ]] && [[ ${BASH_XTRACEFD} != "2" ]] && ! _bx::options::quiet; then
    _bx::display::warning "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} BASH_XTRACEFD is not supported, resetting it to stderr."

    BASH_XTRACEFD=2
  fi

  _bx::recipes::invoke ${positional_arguments+"${positional_arguments[@]}"}
}

_bx::main "$@"
