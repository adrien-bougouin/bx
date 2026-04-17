#!/usr/bin/env bash

bake::engine::load () {
  export __BAKE_RECIPES__=()
  export __BAKE_DEFAULT__=""

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue

    # Annotation functions #####################################################
    @default () { export __BAKE_DEFAULT__="${recipe}"; }

    @as () { true; }

    @from () { true; }
    ############################################################################

    # FIXME: extract first line and $(eval ...)
    [[ $(declare -f "${recipe}") =~ "@default" ]] && __BAKE_DEFAULT__="${recipe}"

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  # Annotation functions no longer needed ######################################
  @default () { true; }
  @as      () { true; }
  @from    () { true; }
  ##############################################################################

  readonly __BAKE_RECIPES__
  readonly __BAKE_DEFAULT__
}

bake::engine::list () {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return

  echo "Recipes:"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    echo "- ${recipe}"
  done
}

bake::engine::exec () {
  local recipe=$1
  local args=("${@:2}")

  printf "$(tput bold)%s%s$(tput sgr0)\n" "${recipe}" "${args+" ${args[*]}"}"

  (eval "${recipe}" "${args+"${args[@]}"}")
}
