#!/bin/bash

__BX_ANNOTATIONS__=()

_bx::annotations::register() {
  __BX_ANNOTATIONS__+=("$1")
}

_bx::annotations::include() {
  [[ ${#__BX_ANNOTATIONS__[@]} -eq 0 ]] && return "${__BOOL_FALSE__}"

  local candidate="$1"

  local annotation
  for annotation in "${__BX_ANNOTATIONS__[@]}"; do
    [[ ${candidate} == "${annotation}" ]] && return "${__BOOL_TRUE__}"
  done

  return "${__BOOL_FALSE__}"
}

# TODO: validation (annotations only allowed at the beginning
_bx::recipe::load_annotations() {
  local recipe

  recipe="$1"

  _bx::annotation_parsing_stack::push "${recipe}"

  local line
  local line_count=0
  while IFS='' read -r line; do
    ((line_count++))

    # Skip the first two lines, which are part of the recipe's function
    # declaration.
    [[ ${line_count} -gt 2 ]] || continue

    # Trim spaces.
    line="${line#"${line%%[![:space:]]*}"}"

    # If the recipe is declared as a subshell, there are additional parentheses,
    # on the first and last line, that need to be striped.
    line="${line#\(}"
    line="${line%\)}"
    line="${line#"${line%%[![:space:]]*}"}"

    local annotation_candidate_name

    annotation_candidate_name="${line%% *}"
    annotation_candidate_name="${annotation_candidate_name%;}"

    # Annotations should be first in the recipe; bx can stop parsing annotations
    # as soon as it reaches a regular instruction.
    _bx::annotations::include "${annotation_candidate_name}" || break

    eval "${line}"
  done < <(declare -f "${recipe}")

  _bx::annotation_parsing_stack::pop
}

source "${__BX_SRC_PATH__}/annotations/confirm.sh"
source "${__BX_SRC_PATH__}/annotations/default.sh"
source "${__BX_SRC_PATH__}/annotations/help.sh"
