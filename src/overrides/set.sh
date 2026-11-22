#!/usr/bin/env bash
#
# Override for the `set` builtin.

_bx::recipe_registry::register_ignore_patterns "^set$"

################################################################################
# Override the `set` builtin to align xtrace with bx's quiet option.
#
# Arguments:
#   - The arguments to pass to the `set` builtin.
#
# Side effects:
#   - Disables xtrace while the real builtin executes, to not expose bx
#     internals.
#   - Forces xtrace off when `_bx::options::xtrace_enabled` returns false.
#   - Reports invalid arguments relative to the caller.
################################################################################
set() {
  {
    local reenable_xtrace="${__BOOL_FALSE__}"

    if shopt -qo xtrace; then
      if (builtin set "$@" >/dev/null && shopt -qo xtrace); then
        reenable_xtrace="${__BOOL_TRUE__}"
      fi
    fi

    builtin set +x
  } 2>/dev/null

  _bx::overrides::execute_builtin_as_caller set "$@"

  {
    if ! _bx::options::xtrace_enabled; then
      builtin set +x
    elif [[ ${reenable_xtrace} == "${__BOOL_TRUE__}" ]]; then
      builtin set -x
    fi
  } 2>/dev/null
}
