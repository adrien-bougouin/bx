#!/bin/bash

_bake::recipe::invoke() {
  local recipe="$1"
  local args=("${@:2}")
  local recipe_with_args="${recipe}${args+" ${args[*]}"}"

  if ! _bake::recipes::include "${recipe}"; then
    if [[ ${recipe} =~ ^_ ]] && declare -F "${recipe}" >/dev/null 2>&1; then
      _bake::abort "'${recipe_with_args}' is a private function, not a recipe!"
    else
      _bake::abort "No recipe '${recipe_with_args}'!"
    fi
  fi

  if _bake::invocation_stack::includes "${recipe_with_args}"; then
    _bake::display::warning "{{bold}}${__BAKE_CONSTANT_COMMAND_NAME__}:{{normal}} Skipping re-invocation of '${recipe_with_args}'..."

    return
  fi

  local invocation_level

  _bake::invocation_stack::push "${recipe_with_args}"

  invocation_level="$(_bake::invocation_stack::size)"

  if ! _bake::options::quiet; then
    _bake::display::trace "${invocation_level}" "{{bold}}${recipe_with_args}{{normal}} {"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"

  # Don't let shell options changed by the last invoked recipe bleed out.
  # Use `{ ... } 2>/dev/null` in case the invoking recipe did 'set -x'.
  { _bake::utils::shell::reset_options; } 2>/dev/null

  if ! _bake::options::quiet; then
    _bake::display::trace "${invocation_level}" "}"
  fi

  _bake::invocation_stack::pop
}
