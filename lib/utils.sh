#!/usr/bin/env bash

bake:utils:list () {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return

  echo "Recipes:"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    echo "- ${recipe}"
  done
}
