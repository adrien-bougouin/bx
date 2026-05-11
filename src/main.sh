#!/bin/bash

bake::main() (
  set -euo pipefail

  local src_dir
  src_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

  source "${src_dir}/string.sh"
  source "${src_dir}/term.sh"

  source "${src_dir}/cli.sh"
  source "${src_dir}/recipes.sh"

  ##############################################################################

  local command_name=bake
  local text_indent="    "

  bake::abort() {
    bake::term::stderr "%s %s!\n" \
      "${__BAKE_TERM_BOLD__}${command_name}:${__BAKE_TERM_RESET__}" \
      "$(bake::string::capitalize "${1}")"

    exit 1
  }

  # Parse CLI options ##########################################################

  local bakefile

  bake::cli::init "$@"

  # Shift bake option arguments to point to the first recipe to call
  for ((i = 1; i <= __BAKE_ARGPARSE_SHIFT_COUNT__; i++)); do
    shift
  done

  bakefile="${__BAKE_OPTION_BAKEFILE__:-"$(pwd)/Bakefile"}"

  if [[ ! -f ${bakefile} ]] && [[ ${__BAKE_OPTION_HELP__} != true ]]; then
    bake::abort "no recipes"
  fi

  # Load recipes ###############################################################

  [[ -f ${bakefile} ]] && source "${bakefile}"

  bake::recipes::init

  if [[ ${__BAKE_OPTION_HELP__} == true ]]; then
    bake::cli::print_help "${command_name}" "${text_indent}"

    [[ ${#__BAKE_RECIPES__[@]} -gt 0 ]] && printf "\n"

    bake::recipes::print_list "${text_indent}"

    exit 0
  fi

  # Execute requested recipes ##################################################

  # TODO: bake::recipes::exec
  if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
      # shellcheck disable=SC2086
      bake::recipes::exec_recipe $1

      shift
    done
  else
    if [[ -n ${__BAKE_DEFAULT__} ]]; then
      # shellcheck disable=SC2086
      bake::recipes::exec_recipe ${__BAKE_DEFAULT__}
    else
      bake::abort "nothing to do"
    fi
  fi
)
