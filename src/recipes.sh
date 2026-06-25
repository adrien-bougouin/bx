#!/bin/bash

__BAKE_RECIPES__=()

bake::recipes::load() {
  local bakefile="$1"

  [[ -f ${bakefile} ]] && source "${bakefile}"

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue
    bake::annotations::include "${recipe}" && continue

    bake::progress::set_parsing "${recipe}"
    bake::recipe::load_annotations "${recipe}"

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  readonly __BAKE_RECIPES__
}

bake::recipes::count() {
  printf "%d" "${#__BAKE_RECIPES__[@]}"
}

bake::recipes::print_list() {
  [[ $(bake::recipes::count) -eq 0 ]] && return

  local indent="$1"

  printf "Available recipes:\n"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    printf "%s%s\n" "${indent}" "${recipe}"
  done
}

bake::recipes::execute() {
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
