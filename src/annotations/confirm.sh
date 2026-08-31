#!/bin/bash

__BX_RECIPES_TO_CONFIRM__=()

_bx::annotations::register "@confirm"

@confirm() {
  if [[ $(_bx::annotation_parsing_stack::size) -gt 0 ]]; then
    __BX_RECIPES_TO_CONFIRM__+=("$(_bx::annotation_parsing_stack::last)")
  fi
}

_bx::recipe::must_confirm() {
  local recipe="$1"

  [[ ${#__BX_RECIPES_TO_CONFIRM__[@]} -eq 0 ]] && return "${__BX_CONSTANT_FALSE__}"

  local recipe_to_confirm
  for recipe_to_confirm in "${__BX_RECIPES_TO_CONFIRM__[@]}"; do
    [[ ${recipe} == "${recipe_to_confirm}" ]] && return "${__BX_CONSTANT_TRUE__}"
  done

  return "${__BX_CONSTANT_FALSE__}"
}
