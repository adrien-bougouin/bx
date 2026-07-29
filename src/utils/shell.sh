#!/bin/bash

__BAKE_ORIGINAL_SHOPTS__="$-"

readonly __BAKE_ORIGINAL_SHOPTS__

bake::utils::shell::reset_options() {
  bake::utils::shell::restore_options "${__BAKE_ORIGINAL_SHOPTS__}"
}

bake::utils::shell::restore_options() {
  local shopts="$1"

  # 1. Disable current options
  # 2. Enable otions to restore
  set "+$-"
  set "-${shopts}"
}
