#!/bin/bash
#
# Builtins overrides to enforce bx's runtime behavior.

################################################################################
# Override the `set` builtin to prevent xtrace output when bx executes in
# quiet mode.
#
# Side effects:
#   - Disables xtrace via `builtin set +x` when `_bx::options::quiet` returns
#     true.
################################################################################
set() {
  {
    builtin set "$@"
    _bx::options::quiet && builtin set +x || true
  } 2>/dev/null
}
