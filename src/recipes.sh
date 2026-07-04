#!/bin/bash

__BAKE_RECIPES__=()

bake::recipes::_load() {
  local bakefile="$1"

  [[ -f ${bakefile} ]] && source "${bakefile}"

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue
    bake::_annotations::_include "${recipe}" && continue

    bake::_state::_set_parsing "${recipe}"
    bake::recipe::_load_annotations "${recipe}"

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  readonly __BAKE_RECIPES__
}

bake::recipes::_count() {
  printf "%d" "${#__BAKE_RECIPES__[@]}"
}

bake::recipes::print_list() {
  [[ $(bake::recipes::_count) -eq 0 ]] && return

  printf "Available recipes:\n"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    printf "%s%s\n" "${__BAKE_CONSTANT_TEXT_INDENT__}" "${recipe}"
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
    if [[ -n $(bake::recipes::default) ]]; then
      local recipe=("$(bake::recipes::default)")

      bake::recipe::execute "${recipe[@]}"
    else
      bake::abort "nothing to do"
    fi
  fi
}
