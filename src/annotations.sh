#!/bin/bash

__BX_ANNOTATIONS__=()

_bx::annotations::register() {
  __BX_ANNOTATIONS__+=("$1")
}

_bx::annotations::include() {
  [[ ${#__BX_ANNOTATIONS__[@]} -eq 0 ]] && return "${__BX_CONSTANT_FALSE__}"

  local candidate="$1"

  local annotation
  for annotation in "${__BX_ANNOTATIONS__[@]}"; do
    [[ ${candidate} == "${annotation}" ]] && return "${__BX_CONSTANT_TRUE__}"
  done

  return "${__BX_CONSTANT_FALSE__}"
}

# TODO: validation (annotations only allowed at the beginning
_bx::recipe::load_annotations() {
  local recipe

  recipe="$1"

  _bx::annotation_parsing_stack::push "${recipe}"

  local line
  while IFS='' read -r line; do
    line="$(_bx::utils::string::trim "${line}" " ")"
    # Strip subshell surroundings (e.g. '(  @default;').
    line="${line#\(}"
    line="${line%\)}"

    local line_head

    line_head="$(_bx::utils::string::trim "${line}" " ")"
    line_head="${line_head%% *}"
    line_head="${line_head%;}"

    _bx::annotations::include "${line_head}" || continue

    eval "${line}"
  done < <(declare -f "${recipe}")

  _bx::annotation_parsing_stack::pop
}

source "${__BX_SRC_PATH__}/annotations/confirm.sh"
source "${__BX_SRC_PATH__}/annotations/default.sh"
source "${__BX_SRC_PATH__}/annotations/help.sh"
