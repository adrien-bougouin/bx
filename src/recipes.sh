#!/bin/bash

export __BAKE_DEFAULT__

export __BAKE_RECIPES__
export __BAKE_REQUIREMENTS__

bake::recipes::init() {
  local bakefile="$1"
  [[ -f ${bakefile} ]] && source "${bakefile}"

  __BAKE_DEFAULT__=""

  __BAKE_RECIPES__=()
  __BAKE_REQUIREMENTS__=()

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
      for requirement in "$@"; do
        local components=("${requirement}")

        if [[ ${components[0]} == "${recipe}" ]]; then
          bake::abort "circular requirement for recipe '${recipe}'"
        fi
      done

      requirements+=("$@")
    }
    ############################################################################

    # TODO: validation (annotations only allowed at the beginning
    eval "$(bake::recipes::_parse_recipe_annotations "${recipe}")"

    __BAKE_RECIPES__+=("${recipe}")

    if [[ ${#requirements[@]} -gt 0 ]]; then
      __BAKE_REQUIREMENTS__+=("${recipe}" "${requirements[@]}" "--")
    fi
  done < <(declare -F)

  # Disable annotations ######################################################
  @default() { true; }
  @require:() { true; }
  ############################################################################

  readonly __BAKE_DEFAULT__
  readonly __BAKE_RECIPES__
  readonly __BAKE_REQUIREMENTS__
}

bake::recipes::print_list() {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return

  local indent="$1"

  printf "Available recipes:\n"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    printf "%s%s\n" "${indent}" "${recipe}"
  done
}

bake::recipes::exec_recipe() {
  local recipe=$1
  local args=("${@:2}")

  bake::recipes::_exec_recipe_requirements "${recipe}"

  if [[ ${__BAKE_OPTION_QUIET__} == "false" ]]; then
    printf "%s%s%s%s\n" \
      "${__BAKE_TERM_BOLD__}" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "${__BAKE_TERM_RESET__}"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}

bake::recipes::_exec_recipe_requirements() {
  local recipe=$1

  local scan_index=0
  local scan_mode="SEEK" # SEEK, SKIP, EXEC

  for ((scan_index = 0; scan_index < ${#__BAKE_REQUIREMENTS__[@]}; scan_index++)); do
    local requirement="${__BAKE_REQUIREMENTS__[${scan_index}]}"

    if [[ ${scan_mode} == "EXEC" ]] && [[ ${requirement} == "--" ]]; then
      break
    fi

    if [[ ${scan_mode} == "EXEC" ]]; then
      bake::recipes::exec_recipe "${requirement}"
      continue
    fi

    if [[ ${scan_mode} == "SKIP" ]] && [[ ${requirement} == "--" ]]; then
      scan_mode="SEEK"
      continue
    fi

    if [[ ${scan_mode} == "SEEK" ]] && [[ ${requirement} == "${recipe}" ]]; then
      scan_mode="EXEC"
    else
      scan_mode="SKIP"
    fi
  done
}

bake::recipes::_parse_recipe_annotations() {
  local recipe
  local recipe_annotations

  recipe="$1"
  recipe_annotations="$(declare -f "${recipe}" | grep "bake::main\|@default\|@require:")"

  # Strip subshell surroundings (e.g. '  (  @default;').
  recipe_annotations=$(
    # FIXME: avoid using sed, use built-in bash string substitution instead
    printf "%s" "${recipe_annotations}" | sed -E 's/^ *\(//; s/\) *$//'
  )

  printf "%s" "${recipe_annotations}"
}
