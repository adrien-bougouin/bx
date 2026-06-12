#!/bin/bash

__BAKE_ANNOTATION_DIR__="$(dirname "${BASH_SOURCE[0]}")/annotation"
readonly __BAKE_ANNOTATION_DIR__

__BAKE_ANNOTATIONS__=()
source "${__BAKE_ANNOTATION_DIR__}/default.sh"
source "${__BAKE_ANNOTATION_DIR__}/require.sh"
readonly __BAKE_ANNOTATIONS__

bake::recipe::parse_annotations() {
  local recipe
  local recipe_annotations

  recipe="$1"
  # TODO: use __BAKE__ANNOTATIONS__
  recipe_annotations="$(declare -f "${recipe}" | grep "@default\|@require:")"

  # Strip subshell surroundings (e.g. '  (  @default;').
  recipe_annotations=$(
    # FIXME: avoid using sed, use built-in bash string substitution instead
    printf "%s" "${recipe_annotations}" | sed -E 's/^ *\(//; s/\) *$//'
  )

  printf "%s" "${recipe_annotations}"
}
