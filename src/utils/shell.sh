#!/bin/bash

# FIXME: This only support single letter options. `pipefail` won't be captured.
__BX_ORIGINAL_SHOPTS__="$-"

readonly __BX_ORIGINAL_SHOPTS__

_bx::utils::shell::reset_options() {
  _bx::utils::shell::restore_options "${__BX_ORIGINAL_SHOPTS__}"
}

_bx::utils::shell::restore_options() {
  local shopts="$1"

  # 1. Disable current options
  # 2. Enable options to restore
  set "+$-"
  set "-${shopts}"
}
