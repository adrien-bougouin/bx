#!/bin/bash

_bx::recipe::invoke() {
  local invocation_tokens

  read -r -a invocation_tokens <<<"$1"

  local recipe="${invocation_tokens[0]}"
  local invocation="$1"
  local canonical_invocation

  canonical_invocation="$(_bx::recipe::canonicalize_invocation "$1")"

  if ! _bx::recipe_registry::include "${recipe}"; then
    if [[ ${recipe} =~ ^_ ]] && declare -F "${recipe}" >/dev/null 2>&1; then
      _bx::abort "\`${canonical_invocation}\` is a private function, not a recipe!"
    else
      _bx::abort "No recipe \`${canonical_invocation}\`!"
    fi
  fi

  if _bx::invocation_stack::includes "${canonical_invocation}"; then
    _bx::display::warning "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} Skipping re-invocation of \`${canonical_invocation}\`..."

    return
  fi

  if _bx::recipe::must_confirm "${recipe}"; then
    if ! _bx::ui::confirm "Invoke recipe \`${canonical_invocation}\`?"; then
      _bx::abort "Aborted!"
    fi
  fi

  local invocation_level

  _bx::invocation_stack::push "${canonical_invocation}"

  invocation_level="$(_bx::invocation_stack::size)"

  if ! _bx::options::quiet; then
    _bx::display::trace "${invocation_level}" "{{bold}}${canonical_invocation}{{normal}} {"
  fi

  eval "${invocation}"

  # Don't let shell options changed by the last invoked recipe bleed out.
  # Use `{ ... } 2>/dev/null` in case the invoking recipe did `set -x`.
  { _bx::utils::shell::reset_options; } 2>/dev/null

  if ! _bx::options::quiet; then
    _bx::display::trace "${invocation_level}" "}"
  fi

  _bx::invocation_stack::pop
}

_bx::recipe::canonicalize_invocation() {
  local invocation=()
  local canonicalized_invocation=()

  # Safely inject invocation component into array, preserving quote boundaries.
  # For instance, with invocation `recipe "arg 1" "arg 2"`
  # - invocation=("$1")       #=> ('recipe' '"arg' '1"' '"arg' '2')
  # - eval "invocation+=($1)" #=> ('recipe' 'arg 1' 'arg 2')
  eval "invocation+=($1)"

  canonicalized_invocation+=("${invocation[0]}")

  local i
  for ((i = 1; i < ${#invocation[@]}; i++)); do
    local arg

    printf -v arg "'%q' " "${invocation[i]}"

    canonicalized_invocation+=("${arg% }")
  done

  printf "%s" "${canonicalized_invocation[*]}"
}
