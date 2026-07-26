#!/bin/bash

__BAKE_BAKEFILE__=

bake::bakefile() {
  printf "%s" "${__BAKE_BAKEFILE__:-"${__BAKE_WORKING_DIRECTORY__}/Bakefile"}"
}

bake::_set_bakefile() {
  if [[ -n "${__BAKE_BAKEFILE__}" ]]; then
    bake::abort "Too many Bakefiles!"
  fi

  local input_bakefile
  local absolute_bakefile

  input_bakefile="$1"
  absolute_bakefile="$(realpath "${input_bakefile}" 2>/dev/null || true)"

  __BAKE_BAKEFILE__="${absolute_bakefile:-"${input_bakefile}"}"
}
