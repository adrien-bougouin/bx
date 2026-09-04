#!/bin/bash

_bx::recipe::invoke() {
  local recipe="$1"
  local args=("${@:2}")
  # TODO: normalize args to obtain: recipe "arg 1" "arg 2" ...
  local recipe_with_args="${recipe}${args+" ${args[@]}"}"

  if ! _bx::recipes::include "${recipe}"; then
    if [[ ${recipe} =~ ^_ ]] && declare -F "${recipe}" >/dev/null 2>&1; then
      _bx::abort "\`${recipe_with_args}\` is a private function, not a recipe!"
    else
      _bx::abort "No recipe \`${recipe_with_args}\`!"
    fi
  fi

  if _bx::invocation_stack::includes "${recipe_with_args}"; then
    _bx::display::warning "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} Skipping re-invocation of \`${recipe_with_args}\`..."

    return
  fi

  if _bx::recipe::must_confirm "${recipe}"; then
    if ! _bx::ui::confirm "Invoke recipe \`${recipe_with_args}\`?"; then
      _bx::abort "Aborted!"
    fi
  fi

  local invocation_level

  _bx::invocation_stack::push "${recipe_with_args}"

  invocation_level="$(_bx::invocation_stack::size)"

  if ! _bx::options::quiet; then
    _bx::display::trace "${invocation_level}" "{{bold}}${recipe_with_args}{{normal}} {"
  fi

  eval "${recipe_with_args}"

  # Don't let shell options changed by the last invoked recipe bleed out.
  # Use `{ ... } 2>/dev/null` in case the invoking recipe did `set -x`.
  { _bx::utils::shell::reset_options; } 2>/dev/null

  if ! _bx::options::quiet; then
    _bx::display::trace "${invocation_level}" "}"
  fi

  _bx::invocation_stack::pop
}
