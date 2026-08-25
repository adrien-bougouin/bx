#!/bin/bash

# ( <recipe> <line_count> <line> ... )
__BX_RECIPE_HELPS__=()

_bx::annotations::register "@help"

@help() {
  if [[ $# -gt 0 ]] && [[ $(_bx::annotation_parsing_stack::size) -gt 0 ]]; then
    __BX_RECIPE_HELPS__+=("$(_bx::annotation_parsing_stack::last)" "$#" "$@")
  fi
}

_bx::recipe::help() {
  local recipe="$1"

  local i
  for ((i = 0; i < ${#__BX_RECIPE_HELPS__[@]}; i++)); do
    local candidate_recipe="${__BX_RECIPE_HELPS__[i++]}"
    local line_count="${__BX_RECIPE_HELPS__[i++]}"

    if [[ ${candidate_recipe} == "${recipe}" ]]; then
      printf "%s" "${__BX_RECIPE_HELPS__[i++]}"

      local j
      for ((j = i; j < i + line_count - 1; j++)); do
        printf "\n%s" "${__BX_RECIPE_HELPS__[j]}"

      done

      break
    fi

    i=$((i + line_count - 1))
  done
}
