#!/bin/bash

bake::recipe::invoke() {
  local recipe="$1"
  local args=("${@:2}")
  local recipe_with_args="${recipe}${args+" ${args[*]}"}"

  bake::recipes::include "${recipe}" || bake::abort "No recipe '${recipe_with_args}'!"

  local invocation_level

  bake::invocation_stack::push "${recipe_with_args}"

  invocation_level="$(bake::invocation_stack::size)"

  # TODO: remove in favor of bake::invocation_stack::push
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

  bake::invocation_stack::pop
}
