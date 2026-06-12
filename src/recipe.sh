#!/bin/bash

__BAKE_RECIPE_DIR__="$(dirname "${BASH_SOURCE[0]}")/recipe"
readonly __BAKE_RECIPE_DIR__

source "${__BAKE_RECIPE_DIR__}/annotation.sh"

export __BAKE_RECIPES__

bake::recipes::init() {
  local bakefile="$1"
  [[ -f ${bakefile} ]] && source "${bakefile}"

  __BAKE_RECIPES__=()

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue
    # FIXME: use annotation function check
    [[ ${recipe} =~ @default ]] && continue
    [[ ${recipe} =~ @require: ]] && continue

    bake::progress::set_parsing "${recipe}"
    # TODO: do it in annotation file
    __BAKE_REQUIREMENTS__+=("${recipe}")
    # TODO: validation (annotations only allowed at the beginning
    # eval "$(bake::recipe::parse_annotations "${recipe}")"
    eval "$(bake::recipe::parse_annotations "${recipe}")"
    # TODO: do it in annotation file
    __BAKE_REQUIREMENTS__+=("--")

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  # Disable annotations ######################################################
  @require:() { true; }
  ############################################################################

  readonly __BAKE_DEFAULT__
  readonly __BAKE_RECIPES__
  readonly __BAKE_REQUIREMENTS__
}

bake::recipes::print_list() {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return

  local indent="$1"

  printf "Available recipes:\n"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    printf "%s%s\n" "${indent}" "${recipe}"
  done
}

bake::recipes::exec_recipe() {
  local recipe=$1
  local args=("${@:2}")

  bake::progress::set_executing "${recipe}"
  bake::recipes::_exec_recipe_requirements "${recipe}"

  if [[ ${__BAKE_OPTION_QUIET__} == "false" ]]; then
    printf "%s%s%s%s\n" \
      "${__BAKE_TERM_BOLD__}" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "${__BAKE_TERM_RESET__}"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}

bake::recipes::_exec_recipe_requirements() {
  local recipe=$1

  local scan_index=0
  local scan_mode="SEEK" # SEEK, SKIP, EXEC

  for ((scan_index = 0; scan_index < ${#__BAKE_REQUIREMENTS__[@]}; scan_index++)); do
    local requirement="${__BAKE_REQUIREMENTS__[${scan_index}]}"

    if [[ ${scan_mode} == "EXEC" ]] && [[ ${requirement} == "--" ]]; then
      break
    fi

    if [[ ${scan_mode} == "EXEC" ]]; then
      bake::recipes::exec_recipe "${requirement}"
      continue
    fi

    if [[ ${scan_mode} == "SKIP" ]] && [[ ${requirement} == "--" ]]; then
      scan_mode="SEEK"
      continue
    fi

    if [[ ${scan_mode} == "SEEK" ]] && [[ ${requirement} == "${recipe}" ]]; then
      scan_mode="EXEC"
    else
      scan_mode="SKIP"
    fi
  done
}
