#!/bin/bash

__BX_RECIPES__=()

_bx::load_recipes() {
  # TODO: register ignore patterns like for annotations???
  local ignore_pattern='^(_|_?bx::|_?bx$)'

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i | --ignore)
        ignore_pattern="$2"
        shift
        break
        ;;
      *)
        ;;
    esac

    shift
  done

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ${ignore_pattern} ]] && continue
    _bx::annotations::include "${recipe}" && continue

    _bx::recipe::load_annotations "${recipe}"

    __BX_RECIPES__+=("${recipe}")
  done < <(declare -F)

  readonly __BX_RECIPES__
}

_bx::recipes::count() {
  printf "%d" "${#__BX_RECIPES__[@]}"
}

_bx::recipes::print_list() {
  [[ $(_bx::recipes::count) -eq 0 ]] && return

  _bx::display::info "Available recipes:"
  for recipe in "${__BX_RECIPES__[@]}"; do
    local help_lines

    # shellcheck disable=SC2207
    IFS=$'\n' help_lines=(
      $(_bx::recipe::help "${recipe}")
    )

    _bx::display::info "{{indent}}${recipe}"
    if [[ ${#help_lines[@]} -gt 0 ]]; then
      for help_line in "${help_lines[@]}"; do
        _bx::display::info "{{indent}}{{indent}}${help_line}"
      done
    fi
  done
}

_bx::recipes::include() {
  [[ ${#__BX_RECIPES__[@]} -eq 0 ]] && return "${__BX_CONSTANT_FALSE__}"

  local candidate="$1"

  local recipe
  for recipe in "${__BX_RECIPES__[@]}"; do
    [[ ${candidate} == "${recipe}" ]] && return "${__BX_CONSTANT_TRUE__}"
  done

  return "${__BX_CONSTANT_FALSE__}"
}
