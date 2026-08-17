#!/bin/bash

_bake::recipe::invoke() {
  local recipe="$1"
  local args=("${@:2}")
  local recipe_with_args="${recipe}${args+" ${args[*]}"}"

  _bake::recipes::include "${recipe}" || _bake::abort "No recipe '${recipe_with_args}'!"

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
