#!/usr/bin/env bash
#
# Override for the `set` builtin.

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
  _bx::overrides::execute_builtin set "$@"

  { _bx::options::xtrace_enabled || builtin set +x; } 2>/dev/null
}
