#!/bin/bash
#
# User interface utilities for interactive prompts and confirmations.

################################################################################
# Prompt the user for a yes/no confirmation.
#
# Displays a formatted confirmation message (with "[y/N]" suffix) and waits for
# a single character response. Returns true if the user confirms with "y" or
# "Y", false otherwise.
#
# Arguments:
#   message - The confirmation message text.
#
# Outputs:
#   Writes the formatted prompt ("bx: ${message} [y/N] ") to stderr.
#
# Returns:
#   0 (true) if the user confirmed, 1 (false) otherwise.
################################################################################
_bx::ui::confirm() {
  local confirmation_message="$1"

  _bx::display::format "{{bold}}${__BX_CONSTANT_COMMAND_NAME__}:{{normal}} ${confirmation_message} [y/N] " >&2
  read -s -r -n 1
  printf "\n" >&2

  if [[ ${REPLY} == [yY] ]]; then
    return "${__BX_CONSTANT_TRUE__}"
  fi

  return "${__BX_CONSTANT_FALSE__}"

}
