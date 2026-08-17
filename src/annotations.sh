#!/bin/bash

__BAKE_ANNOTATIONS__=()

_bake::annotations::register() {
  __BAKE_ANNOTATIONS__+=("$1")
}

_bake::annotations::include() {
  [[ ${#__BAKE_ANNOTATIONS__[@]} -eq 0 ]] && return "${__BAKE_CONSTANT_FALSE__}"

  local candidate
  local annotation

  candidate="$1"

  for annotation in "${__BAKE_ANNOTATIONS__[@]}"; do
    [[ ${candidate} == "${annotation}" ]] && return "${__BAKE_CONSTANT_TRUE__}"
  done

  return "${__BAKE_CONSTANT_FALSE__}"
}

# TODO: validation (annotations only allowed at the beginning
_bake::recipe::load_annotations() {
  local recipe

  recipe="$1"

  _bake::annotation_parsing_stack::push "${recipe}"

  local line
  while IFS='' read -r line; do
    line="$(_bake::utils::string::trim "${line}" " ")"
    # Strip subshell surroundings (e.g. '(  @default;').
    line="${line#\(}"
    line="${line%\)}"

    local line_head

    line_head="$(_bake::utils::string::trim "${line}" " ")"
    line_head="${line_head%% *}"
    line_head="${line_head%;}"

    _bake::annotations::include "${line_head}" || continue

    eval "${line}"
  done < <(declare -f "${recipe}")

  _bake::annotation_parsing_stack::pop
}

source "${__BAKE_SRC_PATH__}/annotations/default.sh"
source "${__BAKE_SRC_PATH__}/annotations/help.sh"
