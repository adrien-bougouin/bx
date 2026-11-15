#!/usr/bin/env bash
#
# Shell utilities for the bx tool.

################################################################################
# Capture the current shell options state, in the form of `set` and `shopt`
# replayable builtin commands, into a caller-specified variable.
#
# The options are assigned to a variable instead of written to stdout so callers
# can capture them without a command substitution: Bash clears `errexit` in the
# subshell spawned for a command substitution, so it would not reflect the
# current shell's `errexit` state.
#
# Arguments:
#   options_var - Name of the variable to receive the replayable commands.
#
# Side effects:
#   Assigns the captured commands to the variable named by `options_var`.
################################################################################
_bx::utils::shell::current_options() {
  local options_var="$1"
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

  printf -v "${options_var}" "%s" "${replayable_options[*]}"
}

__BX_ORIGINAL_SHOPTS__=""

_bx::utils::shell::current_options __BX_ORIGINAL_SHOPTS__

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
