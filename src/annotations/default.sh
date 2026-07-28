#!/bin/bash

__BAKE_RECIPE_DEFAULT__=""

bake::annotations::register "@default"

@default() {
  if bake::state::is_parsing; then
    if [[ -n "$(bake::recipes::default)" ]]; then
      bake::abort "Too many default recipes!"
    fi

    bake::recipes::set_default "$(bake::state::current_recipe)"
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
