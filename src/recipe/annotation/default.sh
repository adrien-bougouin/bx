#!/bin/bash

__BAKE_ANNOTATIONS__+=("@default")

export __BAKE_DEFAULT__=""

@default() {
  if bake::progress::is_parsing; then
    if [[ -z ${__BAKE_DEFAULT__} ]]; then
      __BAKE_DEFAULT__="$(bake::progress::recipe)"
    else
      bake::abort "too many default recipes"
    fi
  fi
}
