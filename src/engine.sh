#!/bin/bash

export __BAKE_RECIPES__=()
export __BAKE_DEFAULT__=""

bake::engine::load() {
  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue

    # TODO
    # Annotations ##############################################################
    @default() { true; }
    @file:() { true; }
    @require:() { true; }
    ############################################################################

    # FIXME: extract first line and $(eval ...)
    [[ $(declare -f "${recipe}") =~ "@default" ]] && __BAKE_DEFAULT__="${recipe}"

    # Disable annotations ######################################################
    @default() { true; }
    @file:() { true; }
    @require:() { true; }
    ############################################################################

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)
}

bake::engine::list() {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return

  printf "Recipes:\n"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    printf -- "- %s\n" "${recipe}"
    declare -f "${recipe}"
  done
}

bake::engine::exec() {
  local recipe=$1
  local args=("${@:2}")

  printf "%s%s%s%s\n" "$(tput bold)" "${recipe}" "${args+" ${args[*]}"}" "$(tput sgr0)"

  eval "${recipe}" "${args+"${args[@]}"}"
}
