#!/usr/bin/env bash
#
# bx's EXIT trap, used to report failed recipes and run user-defined cleanup.

__BX_EXIT_TRAP_INSTALLED__="${__BOOL_FALSE__}"

__BX_EXIT_TRAP_USER_ACTION__=""

################################################################################
# Record the EXIT trap action defined by the user.
#
# Arguments:
#   action - The action passed to the `trap` builtin; an empty string clears it.
#
# Side effects:
#   Sets __BX_EXIT_TRAP_USER_ACTION__.
################################################################################
_bx::exit_trap::set_user_action() {
  __BX_EXIT_TRAP_USER_ACTION__="${1:-}"
}

################################################################################
# Check whether bx's EXIT trap is installed.
#
# Returns:
#   0 (true) if bx's EXIT trap is installed, 1 (false) otherwise.
################################################################################
_bx::exit_trap::installed() {
  return "${__BX_EXIT_TRAP_INSTALLED__}"
}

################################################################################
# Install bx's EXIT trap.
#
# The trap captures the shell's exit status, runs the user action recorded by
# `_bx::exit_trap::set_user_action` with that status visible as `$?`,  and
# reports failures with `_bx::exit_trap::execute`.
#
# Globals:
#   __BX_EXIT_TRAP_USER_ACTION__ - The user action to run from the trap.
#
# Side effects:
#   - Replaces the shell's EXIT trap with bx's EXIT trap wrapper around the
#     user action.
#   - Sets __BX_EXIT_TRAP_INSTALLED__ to true.
################################################################################
_bx::exit_trap::install() {
  builtin trap '
    {
      __BX_EXIT_TRAP_STATUS__="$?"

      builtin set +x
    } 2>/dev/null

    if [[ -n ${__BX_EXIT_TRAP_USER_ACTION__} ]]; then
      eval "
        # Make sure __BX_EXIT_TRAP_USER_ACTION__ sees the right exit status that
        # triggered the EXIT signal.
        (exit ${__BX_EXIT_TRAP_STATUS__})

        ${__BX_EXIT_TRAP_USER_ACTION__}
      " || true

      { builtin set +x; } 2>/dev/null
    fi

    _bx::utils::shell::reset_options
    _bx::exit_trap::execute "${__BX_EXIT_TRAP_STATUS__}"
  ' EXIT

  __BX_EXIT_TRAP_INSTALLED__="${__BOOL_TRUE__}"
}

################################################################################
# Reinstall bx's EXIT trap after a recipe changes its traps.
#
# The user action is taken from __BX_EXIT_TRAP_USER_ACTION__, which the `trap`
# override keeps up to date; it is not read back from the shell.
#
# Globals:
#   __BX_EXIT_TRAP_INSTALLED__ - Whether bx's EXIT trap is installed.
#
# Side effects:
#   Replaces the shell's EXIT trap when bx's EXIT trap was installed.
################################################################################
_bx::exit_trap::restore() {
  [[ ${__BX_EXIT_TRAP_INSTALLED__} == "${__BOOL_TRUE__}" ]] || return

  _bx::exit_trap::install
}

################################################################################
# Report the root recipe that failed, if any.
#
# Arguments:
#   status - The exit status captured when the EXIT trap fired.
#
# Outputs:
#   Writes a bx-prefixed summary naming the root recipe and its status to
#   stderr when a recipe is on the invocation stack.
#
# Returns:
#   The given status.
################################################################################
_bx::exit_trap::execute() {
  local status="$1"

  [[ ${status} -ne 0 ]] || return "${status}"
  [[ $(_bx::invocation_stack::size) -gt 0 ]] || return "${status}"

  local root_recipe
  local status_message

  root_recipe="$(_bx::invocation_stack::root)"
  status_message="Recipe \`${root_recipe}\` exited with status ${status}!"

  _bx::display::error \
    "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} ${status_message}"

  return "${status}"
}
