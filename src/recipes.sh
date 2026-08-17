#!/bin/bash

__BAKE_RECIPES__=()

_bake::load_recipes() {
  local ignore_pattern='^(_?bake::|_?bake$)'

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
    _bake::annotations::include "${recipe}" && continue

    _bake::recipe::load_annotations "${recipe}"

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  readonly __BAKE_RECIPES__
}

_bake::recipes::count() {
  printf "%d" "${#__BAKE_RECIPES__[@]}"
}

_bake::recipes::print_list() {
  [[ $(_bake::recipes::count) -eq 0 ]] && return

  _bake::display::info "Available recipes:"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    local help_lines

    # shellcheck disable=SC2207
    IFS=$'\n' help_lines=(
      $(_bake::recipe::help "${recipe}")
    )

    _bake::display::info "{{indent}}${recipe}"
    if [[ ${#help_lines[@]} -gt 0 ]]; then
      for help_line in "${help_lines[@]}"; do
        _bake::display::info "{{indent}}{{indent}}${help_line}"
      done
    fi
  done
}

_bake::recipes::include() {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return "${__BAKE_CONSTANT_FALSE__}"

  local candidate
  local recipe

  recipe="$1"

  for candidate in "${__BAKE_RECIPES__[@]}"; do
    [[ ${candidate} == "${recipe}" ]] && return "${__BAKE_CONSTANT_TRUE__}"
  done

  return "${__BAKE_CONSTANT_FALSE__}"
}

_bake::recipes::invoke() {
  if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
      # shellcheck disable=SC2086
      _bake::recipe::invoke $1

      shift
    done
  else
    if [[ -n $(_bake::recipes::default) ]]; then
      local default_recipe

      default_recipe="$(_bake::recipes::default)"

      # shellcheck disable=SC2086
      _bake::recipe::invoke ${default_recipe}
    else
      _bake::abort "Nothing to do!"
    fi
  fi
}
