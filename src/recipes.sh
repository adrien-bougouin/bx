#!/bin/bash

__BAKE_RECIPES__=()

bake::load_recipes() {
  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ^bake: ]] && continue
    bake::annotations::include "${recipe}" && continue

    bake::state::set_parsing "${recipe}"
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
    bake::display::info "{{indent}}${recipe}"
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
  # FIXME: If we make proper public interface, we won't need this here.
  #
  # Because this function can be used to invoke recipes from within other recipe
  # invocation, we need to reset the shell options to default before starting
  # the new invocations. Then, we will have to restore the options set by the
  # invoking recipe, to let it continue its execution with the expected shell
  # options.
  #
  # Note: we use `{ ... } 2>/dev/null` in case the invoking recipe did `set -x`.
  {
    local shopts="$-"

    bake::utils::shell::reset_options
  } 2>/dev/null

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

  bake::utils::shell::restore_options "${shopts}"
}
