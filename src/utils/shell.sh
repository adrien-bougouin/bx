#!/bin/bash
#
# Shell utilities for the bx tool.

################################################################################
# Capture the current shell options state, in the form of `set` and `shopt`
# builtin commands.
#
# Outputs:
#   Writes replayable set commands to stdout.
################################################################################
_bx::utils::shell::current_options() {
  local replayable_options=()

  replayable_options+=("builtin set")
  while IFS= read -r set_cmd; do
    replayable_options+=("${set_cmd#set}")
  done < <(shopt -p -o)

  local shopts_u=()
  local shopts_s=()
  while IFS= read -r shopt_cmd; do
    if [[ ${shopt_cmd} =~ ^shopt\ -u ]]; then
      shopts_u+=("${shopt_cmd#shopt -u}")
    else
      shopts_s+=("${shopt_cmd#shopt -s}")
    fi
  done < <(shopt -p)

  if [[ ${#shopts_u[@]} -gt 0 ]]; then
    replayable_options+=(";" "builtin shopt -u" "${shopts_u[@]}")
  fi

  if [[ ${#shopts_s[@]} -gt 0 ]]; then
    replayable_options+=(";" "builtin shopt -s" "${shopts_s[@]}")
  fi

  printf "%s" "${replayable_options[*]}"
}

__BX_ORIGINAL_SHOPTS__="$(_bx::utils::shell::current_options)"

readonly __BX_ORIGINAL_SHOPTS__

################################################################################
# Reset the current shell options to those captured when this file was sourced.
#
# Side effects:
#   Resets the shell options to the values captured at source time.
################################################################################
_bx::utils::shell::reset_options() {
  _bx::utils::shell::restore_options "${__BX_ORIGINAL_SHOPTS__}"
}

################################################################################
# Restore given shell options.
#
# Arguments:
#   - The shell options to restore, in the form of commands as given by
#     `_bx::utils::shell::current_options`.
#
# Side effects:
#   Resets the shell options to the values given by `options`.
################################################################################
_bx::utils::shell::restore_options() {
  # - Use builtin `set` instead of the `set` that bx overrides (slower)
  # - Temporarily silence stderr in case the options turn on xtrace
  { eval "$1"; } 2>/dev/null
}
