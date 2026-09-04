#!/bin/bash

_bx::recipe::invoke() {
  # shellcheck disable=SC2206
  local invocation_tokens=($1)

  local recipe="${invocation_tokens[0]}"
  local recipe_invocation="$1"

  if ! _bx::recipes::include "${recipe}"; then
    if [[ ${recipe} =~ ^_ ]] && declare -F "${recipe}" >/dev/null 2>&1; then
      _bx::abort "\`${recipe_invocation}\` is a private function, not a recipe!"
    else
      _bx::abort "No recipe \`${recipe_invocation}\`!"
    fi
  fi

  if _bx::invocation_stack::includes "${recipe_invocation}"; then
    _bx::display::warning "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} Skipping re-invocation of \`${recipe_invocation}\`..."

    return
  fi

  if _bx::recipe::must_confirm "${recipe}"; then
    if ! _bx::ui::confirm "Invoke recipe \`${recipe_invocation}\`?"; then
      _bx::abort "Aborted!"
    fi
  fi

  local invocation_level

  _bx::invocation_stack::push "${recipe_invocation}"

  invocation_level="$(_bx::invocation_stack::size)"

  if ! _bx::options::quiet; then
    _bx::display::trace "${invocation_level}" "{{bold}}${recipe_invocation}{{normal}} {"
  fi

  eval "${recipe_invocation}"

  # Don't let shell options changed by the last invoked recipe bleed out.
  # Use `{ ... } 2>/dev/null` in case the invoking recipe did `set -x`.
  { _bx::utils::shell::reset_options; } 2>/dev/null

  if ! _bx::options::quiet; then
    _bx::display::trace "${invocation_level}" "}"
  fi

  _bx::invocation_stack::pop
}
