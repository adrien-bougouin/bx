#!/usr/bin/env bash

bake:utils:list () {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return

  echo "Recipes:"
  for r in "${__BAKE_RECIPES__[@]}"; do
    echo "- ${r}"
  done
}
