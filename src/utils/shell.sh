#!/bin/bash

# FIXME: This only support single letter options. 'pipefail' won't be captured.
__BAKE_ORIGINAL_SHOPTS__="$-"

readonly __BAKE_ORIGINAL_SHOPTS__

_bake::utils::shell::reset_options() {
  _bake::utils::shell::restore_options "${__BAKE_ORIGINAL_SHOPTS__}"
}

_bake::utils::shell::restore_options() {
  local shopts="$1"

  # 1. Disable current options
  # 2. Enable options to restore
  set "+$-"
  set "-${shopts}"
}
