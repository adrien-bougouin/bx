#!/usr/bin/env bash
#
# Override for the `set` builtin.

_bx::recipe_registry::register_ignore_patterns "^set$"

################################################################################
# Override the `set` builtin to keep bx internals out of xtrace output.
#
# The requested options are replayed silently in a subshell to detect whether
# they leave xtrace enabled. xtrace is then disabled inside
# `{ ... } 2>/dev/null` while the real builtin runs, suppressing bx internals'
# xtrace output when the calling recipe already had `set -x` enabled. It is
# re-enabled afterwards when it was already on and the requested options do not
# turn it off.
#
# Arguments:
#   - The arguments to pass to the `set` builtin.
#
# Side effects:
#   - Disables xtrace while the real builtin executes.
#   - Preserves an already-enabled xtrace across unrelated option changes.
#   - Forces xtrace off when `_bx::options::xtrace_enabled` returns false.
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

  _bx::overrides::execute_builtin set "$@"

  {
    if ! _bx::options::xtrace_enabled; then
      builtin set +x
    elif [[ ${reenable_xtrace} == "${__BOOL_TRUE__}" ]]; then
      builtin set -x
    fi
  } 2>/dev/null
}
