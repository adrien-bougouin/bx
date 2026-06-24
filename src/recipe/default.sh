#!/bin/bash

__BAKE_RECIPE_DEFAULT__=""

bake::register_recipe_annotation "@default"

@default() {
  if bake::progress::is_parsing; then
    if [[ -n $(bake::default_recipe) ]]; then
      bake::abort "too many default recipes"
    fi

    bake::set_default_recipe "$(bake::progress::recipe)"
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
