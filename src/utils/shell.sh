#!/bin/bash
#
# Shell utilities for the bx tool.

# FIXME: This only support single letter options. `pipefail` won't be captured.
__BX_ORIGINAL_SHOPTS__="$-"

readonly __BX_ORIGINAL_SHOPTS__

################################################################################
# Reset the current shell options to those captured when this file was sourced.
#
# Side effects:
#   Re-enables the shell options captured at source time via `set`.
################################################################################
_bx::utils::shell::reset_options() {
  _bx::utils::shell::restore_options "${__BX_ORIGINAL_SHOPTS__}"
}

################################################################################
# Restore a specific set of shell options.
#
# First disables every currently-set option, then enables the options present
# in the given shopts string (in the same format as `${-}`).
#
# Arguments:
#   shopts - The shell options to restore.
#
# Side effects:
#   Modifies the current shell options via `set`.
################################################################################
_bx::utils::shell::restore_options() {
  local shopts="$1"

  # 1. Disable current options
  # 2. Enable options to restore
  set "+$-"
  set "-${shopts}"
}
