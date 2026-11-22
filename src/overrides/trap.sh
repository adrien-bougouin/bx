#!/usr/bin/env bash
#
# Override for the `trap` builtin.

_bx::recipe_registry::register_ignore_patterns "^trap$"

################################################################################
# Override the `trap` builtin to install user-defined EXIT trap while preserving
# bx's own EXIT trap.
#
# Arguments:
#   - The arguments to pass to the `trap` builtin.
#
# Side effects:
#   - Disables xtrace while the real builtin executes, to not expose bx
#     internals.
#   - Reinstall bx's own EXIT trap together with the user-defined EXIT trap.
#   - Reports invalid arguments relative to the caller.
################################################################################
trap() {
  {
    local options_ref

    _bx::utils::shell::current_options options_ref
    _bx::utils::shell::reset_options
  } 2>/dev/null

  local trap_status=0

  # Simple non-mutating trap cases.
  if [[ $# -eq 0 || $1 == -l || $1 == -p ]]; then
    _bx::overrides::execute_builtin_as_caller trap "$@"
    _bx::utils::shell::restore_options "${options_ref}"

    return
  fi

  local trap_arguments=("$@")
  local action_index=0

  if [[ ${trap_arguments[0]} == -- ]]; then
    action_index=1
  fi

  local user_action="${trap_arguments[action_index]:-}"

  if [[ ${user_action} == - ]]; then
    user_action=""
  fi

  local affects_exit="${__BOOL_FALSE__}"

  local signal
  for signal in "${trap_arguments[@]:$((action_index + 1))}"; do
    if [[ ${signal} == EXIT ]] || [[ ${signal} == 0 ]]; then
      affects_exit="${__BOOL_TRUE__}"
    fi
  done

  if ((${#trap_arguments[@]} - action_index - 1 == 0)); then
    # Single argument is a signal spec to reset, not a trap action.
    if [[ ${user_action} == EXIT ]] || [[ ${user_action} == 0 ]]; then
      affects_exit="${__BOOL_TRUE__}"
    fi

    user_action=""
  fi

  _bx::overrides::execute_builtin_as_caller --no-exit trap "$@" || trap_status="$?"

  if [[ ${affects_exit} == "${__BOOL_TRUE__}" ]]; then
    if [[ ${trap_status} -eq 0 ]]; then
      _bx::exit_trap::set_user_action "${user_action}"
    fi

    _bx::exit_trap::restore
  fi

  if [[ ${trap_status} -ne 0 ]]; then
    exit "${trap_status}"
  fi

  _bx::utils::shell::restore_options "${options_ref}"
}
