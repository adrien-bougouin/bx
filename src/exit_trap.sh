#!/usr/bin/env bash

__BX_EXIT_TRAP_INSTALLED__="${__BOOL_FALSE__}"

__BX_EXIT_TRAP_USER_ACTION__=

# TODO: Documentation
_bx::exit_trap::installed() {
  return "${__BX_EXIT_TRAP_INSTALLED__}"
}

# TODO: Documentation
_bx::exit_trap::install() {
  builtin trap '
    {
      __BX_EXIT_TRAP_STATUS__="$?"

      builtin set +x
    } 2>/dev/null

    if [[ -n ${__BX_EXIT_TRAP_USER_ACTION__} ]]; then
      eval "${__BX_EXIT_TRAP_USER_ACTION__}"

      { builtin set +x; } 2>/dev/null
    fi

    _bx::utils::shell::reset_options
    _bx::exit_trap::execute "${__BX_EXIT_TRAP_STATUS__}"
  ' EXIT

  __BX_EXIT_TRAP_INSTALLED__="${__BOOL_TRUE__}"
}

# TODO: Documentation
_bx::exit_trap::reinstall() {
  [[ ${__BX_EXIT_TRAP_INSTALLED__} == "${__BOOL_TRUE__}" ]] || return

  local user_exit_trap
  user_exit_trap="$(builtin trap -p EXIT)"

  if [[ -n ${user_exit_trap} ]]; then
    local user_exit_trap_action

    user_exit_trap_action="${user_exit_trap#trap }"
    user_exit_trap_action="${user_exit_trap_action#-- }"
    user_exit_trap_action="${user_exit_trap_action/% EXIT/}"
    user_exit_trap_action="$(eval "echo ${user_exit_trap_action}")"

    __BX_EXIT_TRAP_USER_ACTION__="${user_exit_trap_action}"
  fi

  _bx::exit_trap::install
}

# TODO: Documentation
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
