#!/bin/bash

__BAKE_RECIPES__=()

bake::load_recipes() {
  local ignore_pattern='^(bake::|bake$)'

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
    bake::annotations::include "${recipe}" && continue

    bake::recipe::load_annotations "${recipe}"

    __BAKE_RECIPES__+=("${recipe}")
  done < <(declare -F)

  readonly __BAKE_RECIPES__
}

bake::recipes::count() {
  printf "%d" "${#__BAKE_RECIPES__[@]}"
}

bake::recipes::print_list() {
  [[ $(bake::recipes::count) -eq 0 ]] && return

  bake::display::info "Available recipes:"
  for recipe in "${__BAKE_RECIPES__[@]}"; do
    local help_lines

    # shellcheck disable=SC2207
    IFS=$'\n' help_lines=(
      $(bake::recipe::help "${recipe}")
    )

    bake::display::info "{{indent}}${recipe}"
    if [[ ${#help_lines[@]} -gt 0 ]]; then
      for help_line in "${help_lines[@]}"; do
        bake::display::info "{{indent}}{{indent}}${help_line}"
      done
    fi
  done
}

bake::recipes::include() {
  [[ ${#__BAKE_RECIPES__[@]} -eq 0 ]] && return "${__BAKE_CONSTANT_FALSE__}"

  local candidate
  local recipe

  recipe="$1"

  for candidate in "${__BAKE_RECIPES__[@]}"; do
    [[ ${candidate} == "${recipe}" ]] && return "${__BAKE_CONSTANT_TRUE__}"
  done

  return "${__BAKE_CONSTANT_FALSE__}"
}

bake::recipes::invoke() {
  if [[ $# -gt 0 ]]; then
    while [[ $# -gt 0 ]]; do
      # shellcheck disable=SC2086
      bake::recipe::invoke $1

      shift
    done
  else
    if [[ -n $(bake::recipes::default) ]]; then
      local default_recipe

      default_recipe="$(bake::recipes::default)"

      # shellcheck disable=SC2086
      bake::recipe::invoke ${default_recipe}
    else
      bake::abort "Nothing to do!"
    fi
  fi
}
