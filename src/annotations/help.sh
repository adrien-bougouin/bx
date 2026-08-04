#!/bin/bash

# ( <recipe> <line_count> <line> ... )
__BAKE_RECIPE_HELPS__=()

bake::annotations::register "@help"

@help() {
  if [[ $# -gt 0 ]] && bake::state::is_parsing; then
    __BAKE_RECIPE_HELPS__+=("$(bake::state::current_recipe)" "$#" "$@")
  fi
}

bake::recipe::help() {
  local recipe="$1"

  local i
  for ((i = 0; i < ${#__BAKE_RECIPE_HELPS__[@]}; i++)); do
    local candidate_recipe="${__BAKE_RECIPE_HELPS__[i++]}"
    local line_count="${__BAKE_RECIPE_HELPS__[i++]}"

    if [[ ${candidate_recipe} == "${recipe}" ]]; then
      printf "%s" "${__BAKE_RECIPE_HELPS__[i++]}"

      local j
      for ((j = i; j < i + line_count - 1; j++)); do
        printf "\n%s" "${__BAKE_RECIPE_HELPS__[j]}"

      done

      break
    fi

    i=$((i + line_count - 1))
  done
}
