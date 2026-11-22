#!/usr/bin/env bash

__BX_RECIPE_DEFAULT__=""

_bx::annotations::register "@default"

@default() {
  if [[ $(_bx::annotation_parsing_stack::size) -gt 0 ]]; then
    local current_recipe
    local existing_default

    current_recipe="$(_bx::annotation_parsing_stack::last)"
    existing_default="$(_bx::recipe_registry::default)"

    if [[ -n ${existing_default} ]]; then
      _bx::abort \
        "Too many default recipes: \`${existing_default}\` and \`${current_recipe}\`!"
    fi

    __BX_RECIPE_DEFAULT__="${current_recipe}"
  fi
}

_bx::recipe_registry::default() {
  printf "%s" "${__BX_RECIPE_DEFAULT__}"
}
