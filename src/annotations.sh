#!/bin/bash

__BAKE_ANNOTATIONS__=()

bake::annotations::register() {
  __BAKE_ANNOTATIONS__+=("$1")
}

bake::annotations::include() {
  [[ ${#__BAKE_ANNOTATIONS__[@]} -eq 0 ]] && return 1

  local candidate
  local annotation

  candidate="$1"

  for annotation in "${__BAKE_ANNOTATIONS__[@]}"; do
    [[ ${candidate} =~ ${annotation} ]] && return 0
  done

  return 1
}

# TODO: validation (annotations only allowed at the beginning
bake::recipe::load_annotations() {
  local recipe
  local recipe_annotations

  recipe="$1"
  # TODO: use __BAKE__ANNOTATIONS__
  # FIXME: avoid using grep
  recipe_annotations="$(declare -f "${recipe}" | grep "@default\|@require:")" || true

  # Strip subshell surroundings (e.g. '  (  @default;').
  recipe_annotations=$(
    # FIXME: avoid using sed, use built-in bash string substitution instead
    printf "%s" "${recipe_annotations}" | sed -E 's/^ *\(//; s/\) *$//'
  ) || true

  eval "${recipe_annotations}"
}

source "${__BAKE_SRC_PATH__}/annotations/default.sh"
source "${__BAKE_SRC_PATH__}/annotations/require.sh"
