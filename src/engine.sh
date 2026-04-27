#!/bin/bash

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
        # TODO
        :
      fi
    }

    @require:() {
      requirements+=("$@")
    }
    ############################################################################

    # TODO: validation (annotations only allowed at the beginning
    # TODO: subshell support (sed -E 's/([()])/\1\n/g')--comment+test
    eval "$(declare -f "${recipe}" \
      | sed -E 's/([()])/\1\n/g' \
      | grep "@default\|@require:")"

    # Disable annotations ######################################################
    @default() { true; }
    @require:() { true; }
    ############################################################################

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)
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
