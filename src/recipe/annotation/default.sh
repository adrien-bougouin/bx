#!/bin/bash

__BAKE_ANNOTATIONS__+=("@default")

__BAKE_RECIPE_DEFAULT__=""

@default() {
  if bake::progress::is_parsing; then
    if [[ ! -z $(bake::recipe::default) ]]; then
      bake::abort "too many default recipes"
    fi

    bake::recipe::set_default "$(bake::progress::recipe)"
  fi
}

bake::recipe::default() {
  echo "${__BAKE_RECIPE_DEFAULT__}"
}

bake::recipe::set_default() {
  if [[ $# -gt 1 ]]; then
    bake::abort "too many default recipes"
  fi

  __BAKE_RECIPE_DEFAULT__="$1"
}
