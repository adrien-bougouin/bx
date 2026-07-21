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

  bake::display::info "Available recipes:"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    bake::display::info "{{indent}}${recipe}"
  done
}

bake::recipes::include() {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return "${__BAKE_CONSTANT_FALSE__}"

  local candidate
  local recipe

  recipe="$1"

  for candidate in "${__BAKE_RECIPES__[@]}"; do
    [[ ${candidate} == "${recipe}" ]] && return "${__BAKE_CONSTANT_TRUE__}"
  done

  return "${__BAKE_CONSTANT_FALSE__}"
}

bake::recipes::invoke() {
  if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
      # shellcheck disable=SC2086
      bake::recipe::invoke $1

      shift
    done
  else
    if [[ -n $(bake::recipes::default) ]]; then
      local default_recipe

      default_recipe="$(bake::recipes::default)"

      # shellcheck disable=SC2086
      bake::recipe::invoke ${default_recipe}
    else
      bake::abort "Nothing to do!"
    fi
  fi
}
