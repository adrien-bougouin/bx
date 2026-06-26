#!/bin/bash

__BAKE_RECIPE_DEFAULT__=""

bake::annotations::register "@default"

@default() {
  if bake::state::is_parsing; then
    if [[ -n $(bake::default_recipe) ]]; then
      bake::abort "too many default recipes"
    fi

    bake::set_default_recipe "$(bake::state::current_recipe)"
  fi
}

bake::default_recipe() {
  printf "%s" "${__BAKE_RECIPE_DEFAULT__}"
}

bake::set_default_recipe() {
  if [[ $# -gt 1 ]]; then
    bake::abort "too many default recipes"
  fi

  __BAKE_RECIPE_DEFAULT__="$1"
}
