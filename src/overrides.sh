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
  builtin set "$@"

  { _bx::options::xtrace_enabled || builtin set +x; } 2>/dev/null
}
