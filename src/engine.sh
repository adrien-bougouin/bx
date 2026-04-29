#!/bin/bash

# TODO: rename recipes??? e.g. bake::recipes::load

export __BAKE_DEFAULT__=""

export __BAKE_RECIPES__=()
export __BAKE_REQUIREMENTS__=()

bake::engine::load() {
  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue

    local requirements=()

    # Annotations ##############################################################
    @default() {
      if [[ -z ${__BAKE_DEFAULT__} ]]; then
        __BAKE_DEFAULT__="${recipe}"
      else
        bake::abort "too many default recipes"
      fi
    }

    @require:() {
      requirements+=("$@")
    }
    ############################################################################

    # TODO: validation (annotations only allowed at the beginning
    eval "$(bake::engine::_parse_recipe_annotations "${recipe}")"

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  # Disable annotations ######################################################
  @default() { true; }
  @require:() { true; }
  ############################################################################
}

bake::engine::list() {
  [[ ${#__BAKE_RECIPES__} -eq 0 ]] && return

  printf "Available recipes:\n"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    printf "%s%s\n" "${__BAKE_INDENT__}" "${recipe}"
  done
}

bake::engine::exec() {
  local recipe=$1
  local args=("${@:2}")

  if [[ ${__BAKE_OPTION_QUIET__} == "false" ]]; then
    printf "%s%s%s%s\n" \
      "${__BAKE_TERM_BOLD__}" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "${__BAKE_TERM_RESET__}"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}

bake::engine::_parse_recipe_annotations() {
  local recipe
  local recipe_annotations

  recipe="$1"
  recipe_annotations="$(declare -f "${recipe}" | grep "@default\|@require:")"

  # Strip subshell surroundings (e.g. '  (  @default;').
  recipe_annotations=$(
    printf "%s" "${recipe_annotations}" | sed -E 's/^ *\(//; s/\) *$//'
  )

  printf "%s" "${recipe_annotations}"
}
