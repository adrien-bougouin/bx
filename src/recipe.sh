#!/bin/bash

source "${__BAKE_SRC_PATH__}/recipe/annotation.sh"
source "${__BAKE_SRC_PATH__}/recipe/default.sh"
source "${__BAKE_SRC_PATH__}/recipe/require.sh"

__BAKE_RECIPES__=()

bake::load_recipes() {
  local bakefile="$1"

  [[ -f ${bakefile} ]] && source "${bakefile}"

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue
    bake::is_recipe_annotation "${recipe}" && continue

    bake::progress::set_parsing "${recipe}"
    bake::recipe::load_annotations "${recipe}"

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  readonly __BAKE_RECIPES__
}

bake::recipe_count() {
  echo "${#__BAKE_RECIPES__[@]}"
}

bake::print_recipe_list() {
  [[ $(bake::recipe_count) -eq 0 ]] && return

  local indent="$1"

  printf "Available recipes:\n"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    printf "%s%s\n" "${indent}" "${recipe}"
  done
}

bake::execute_recipes() {
  if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
      # shellcheck disable=SC2086
      bake::recipe::execute $1

      shift
    done
  else
    if [[ -n $(bake::default_recipe) ]]; then
      # shellcheck disable=SC2086,SC2046
      bake::recipe::execute $(bake::default_recipe)
    else
      bake::abort "nothing to do"
    fi
  fi
}

bake::recipe::execute() {
  local recipe=$1
  local args=("${@:2}")

  bake::progress::set_executing "${recipe}"
  bake::recipe::execute_requirements "${recipe}"

  if [[ ${__BAKE_OPTION_QUIET__} == "false" ]]; then
    printf "%s%s%s%s\n" \
      "${__BAKE_TERM_BOLD__}" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "${__BAKE_TERM_RESET__}"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}
