#!/bin/bash

__BAKE_RECIPE_DEFAULT__=""

bake::_annotations::_register "@default"

@default() {
  if bake::_state::_is_parsing; then
    if [[ -n "$(bake::recipes::default)" ]]; then
      bake::abort "Too many default recipes!"
    fi

    bake::recipes::set_default "$(bake::_state::_current_recipe)"
  fi
}

bake::recipes::default() {
  printf "%s" "${__BAKE_RECIPE_DEFAULT__}"
}

bake::recipes::set_default() {
  if [[ $# -gt 1 ]]; then
    bake::abort "Too many default recipes!"
  fi

  __BAKE_RECIPE_DEFAULT__="$1"
}
