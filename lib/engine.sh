#!/usr/bin/env bash

__BAKE_RECIPES__=()
__BAKE_DEFAULT__=""

bake:engine:load () {
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
}

bake:engine:get_default () {
  echo "${__BAKE_DEFAULT__}"
}

bake:engine:exec () {
  local recipe=$1
  local args=("${@:2}")

  printf "$(tput bold)%s%s$(tput sgr0)\n" "${recipe}" "${args+" ${args[*]}"}"

  (eval "${recipe}" "${args+"${args[@]}"}")
}
