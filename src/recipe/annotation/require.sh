#!/bin/bash

__BAKE_ANNOTATIONS__+=("@require:")

__BAKE_REQUIREMENTS__=()

@require:() {
  if bake::progress::is_parsing; then
    local recipe

    recipe="$(bake::progress::recipe)"

    for requirement in "$@"; do
      local components=("${requirement}")

      if [[ ${components[0]} == "${recipe}" ]]; then
        bake::abort "circular requirement for recipe '${recipe}'"
      fi
    done

    __BAKE_REQUIREMENTS__+=("$@")
  fi
}
