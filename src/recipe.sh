#!/bin/bash

bake::recipe::invoke() {
  local recipe="$1"
  local args=("${@:2}")
  local recipe_with_args="${recipe}${args+" ${args[*]}"}"

  local invocation_level

  invocation_level="$(bake::trace::invocation_level)"

  bake::recipes::include "${recipe}" || bake::abort "No recipe '${recipe_with_args}'!"

  bake::state::set_invoking "${recipe}"

  if ! bake::options::quiet; then
    bake::display::trace "${invocation_level}" "{{bold}}${recipe_with_args}{{normal}} {"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"

  # Don't let shell options changed by the last invoked recipe bleed out.
  # Use `{ ... } 2>/dev/null` in case the invoking recipe did 'set -x'.
  { bake::utils::shell::reset_options; } 2>/dev/null

  if ! bake::options::quiet; then
    bake::display::trace "${invocation_level}" "}"
  fi
}
