#!/usr/bin/env bash
#
# Builtins overrides to enforce bx's runtime behavior.

_bx::recipe_registry::register_ignore_patterns "^set$"

################################################################################
# Override the `set` builtin to prevent xtrace output when bx executes with
# xtrace disabled.
#
# Side effects:
#   - Disables xtrace via `builtin set +x` when `_bx::options::xtrace_enabled`
#     returns false.
################################################################################
set() {
  local caller_source="${BASH_SOURCE[1]}"
  local caller_lineno="${BASH_LINENO[0]}"

  if ! builtin set "$@" 2>/dev/null; then
    printf "%s: line %d: set: %s: invalid option(s)\n" \
      "${caller_source}" \
      "${caller_lineno}" \
      "$*" >&2

    exit 1
  fi

  { _bx::options::xtrace_enabled || builtin set +x; } 2>/dev/null
}
