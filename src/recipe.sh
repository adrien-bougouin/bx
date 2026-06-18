#!/bin/bash

__BAKE_RECIPE_DIR__="$(dirname "${BASH_SOURCE[0]}")/recipe"
readonly __BAKE_RECIPE_DIR__

source "${__BAKE_RECIPE_DIR__}/annotation.sh"
# TODO: source "${__BAKE_RECIPE_DIR__}/default.sh"
# TODO: source "${__BAKE_RECIPE_DIR__}/require.sh"

__BAKE_RECIPES__=()

bake::load_recipes() {
  local bakefile="$1"

  [[ -f ${bakefile} ]] && source "${bakefile}"

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue
    # FIXME: use annotation function check
    [[ ${recipe} =~ @default ]] && continue
    [[ ${recipe} =~ @require: ]] && continue

    bake::progress::set_parsing "${recipe}"
    # TODO: validation (annotations only allowed at the beginning
    eval "$(bake::recipe::parse_annotations "${recipe}")"

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

bake::recipe::exec() {
  local recipe=$1
  local args=("${@:2}")

  bake::progress::set_executing "${recipe}"
  bake::recipe::exec_requirements "${recipe}"

  if [[ ${__BAKE_OPTION_QUIET__} == "false" ]]; then
    printf "%s%s%s%s\n" \
      "${__BAKE_TERM_BOLD__}" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "${__BAKE_TERM_RESET__}"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}
