#!/bin/bash

__BX_ANNOTATIONS__=()

__BX_RECIPE_ANNOTATION_START_PATTERN__="{ *$"

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

_bx::recipe::load_annotations() {
  local recipe

  recipe="$1"

  _bx::annotation_parsing_stack::push "${recipe}"

  local line
  local inside_recipe="${__BOOL_FALSE__}"
      # TODO
  # local done_parsing_annotations="${__BOOL_FALSE__}"
  while IFS='' read -r line; do
    if [[ ${inside_recipe} != "${__BOOL_TRUE__}" ]]; then
      if [[ ${line} =~ ${__BX_RECIPE_ANNOTATION_START_PATTERN__} ]]; then
        # Start parsing and validating the recipe from next line.
        inside_recipe="${__BOOL_TRUE__}"
      fi

      continue
    fi

    # Trim spaces.
    line="${line#"${line%%[![:space:]]*}"}"
    # Strip subshell surroundings (e.g. '(  @default;').
    line="${line#\(}"
    line="${line%\)}"
    # Trim spaces again.
    line="${line#"${line%%[![:space:]]*}"}"

    local line_head

    line_head="${line%% *}"
    line_head="${line_head%;}"

    if _bx::annotations::include "${line_head}"; then
      # TODO
      # if [[ ${done_parsing_annotations} == "${__BOOL_FALSE__}" ]]; then
      eval "${line}"
      # else
      #   _bx::abort "Invalid Bashfile at recipe \`${recipe}\` - Found annotation '${line_head}' after executable code!"
      # fi
      # else
      # Once a Bash instruction is found instead of an annotation, no more
      # annotations are allowed.
      # done_parsing_annotations="${__BOOL_TRUE__}"
    fi
  done < <(declare -f "${recipe}")

  _bx::annotation_parsing_stack::pop
}

source "${__BX_SRC_PATH__}/annotations/confirm.sh"
source "${__BX_SRC_PATH__}/annotations/default.sh"
source "${__BX_SRC_PATH__}/annotations/help.sh"
