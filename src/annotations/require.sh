#!/bin/bash

__BAKE_RECIPE_REQUIREMENTS__=()

__BAKE_RECIPE_REQUIREMENTS_LAST_SEEN_RECIPE__=""

bake::annotations::register "@require:"

@require:() {
  if bake::progress::is_parsing; then
    local recipe
    recipe="$(bake::progress::recipe)"

    if [[ ${recipe} != "${__BAKE_RECIPE_REQUIREMENTS_LAST_SEEN_RECIPE__}" ]]; then
      __BAKE_RECIPE_REQUIREMENTS_LAST_SEEN_RECIPE__="${recipe}"

      __BAKE_RECIPE_REQUIREMENTS__+=("--")
    fi

    local last_index
    last_index=$((${#__BAKE_RECIPE_REQUIREMENTS__[@]} - 1))

    if [[ ${__BAKE_RECIPE_REQUIREMENTS__[${last_index}]} == "--" ]]; then
      __BAKE_RECIPE_REQUIREMENTS__+=("${recipe}")
    fi

    for requirement in "$@"; do
      local components=("${requirement}")

      if [[ ${components[0]} == "${recipe}" ]]; then
        bake::abort "circular requirement for recipe '${recipe}'"
      fi
    done

    __BAKE_RECIPE_REQUIREMENTS__+=("$@")
  fi
}

bake::recipe::execute_requirements() {
  local recipe=$1

  local scan_index=1     # Skip the first "--"
  local scan_mode="SEEK" # SEEK, SKIP, EXEC

  for (( ; scan_index < ${#__BAKE_RECIPE_REQUIREMENTS__[@]}; scan_index++)); do
    local requirement="${__BAKE_RECIPE_REQUIREMENTS__[${scan_index}]}"

    if [[ ${scan_mode} == "SEEK" ]] && [[ ${requirement} == "${recipe}" ]]; then
      scan_mode="EXEC"
      continue
    fi

    if [[ ${scan_mode} == "SKIP" ]] && [[ ${requirement} == "--" ]]; then
      scan_mode="SEEK"
      continue
    fi

    if [[ ${scan_mode} == "EXEC" ]] && [[ ${requirement} != "--" ]]; then
      bake::recipe::execute "${requirement}"
      continue
    fi

    if [[ ${scan_mode} == "EXEC" ]] && [[ ${requirement} == "--" ]]; then
      break
    fi

    scan_mode="SKIP"
  done
}
