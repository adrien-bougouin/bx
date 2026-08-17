#!/bin/bash
#
# Builtins overrides to enforce Bake's runtime behavior.

################################################################################
# Override the `set` builtin to prevent xtrace output when Bake executes in
# quiet mode.
#
# Side effects:
#   - Disables xtrace via `builtin set +x` when `_bake::options::quiet` returns
#     true.
################################################################################
set() {
  {
    builtin set "$@"
    _bake::options::quiet && builtin set +x || true
  } 2>/dev/null
}
