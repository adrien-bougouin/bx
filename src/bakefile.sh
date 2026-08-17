#!/bin/bash

__BAKE_BAKEFILE__=

_bake::load_bakefile() {
  if [[ -z ${__BAKE_BAKEFILE__} ]]; then
    local lookup_path="${__BAKE_WORKING_DIRECTORY__}"

    while [[ ${lookup_path} != "/" ]] && [[ -z ${__BAKE_BAKEFILE__} ]]; do
      local bakefile_candidate="${lookup_path}/Bakefile"

      [[ -f ${bakefile_candidate} ]] && _bake::set_bakefile "${bakefile_candidate}"

      lookup_path="$(dirname "${lookup_path}")"
    done
  fi

  readonly __BAKE_BAKEFILE__

  if [[ -f ${__BAKE_BAKEFILE__} ]]; then
    source "${__BAKE_BAKEFILE__}"
  else
    _bake::abort "No Bakefile!"
  fi
}

_bake::set_bakefile() {
  if [[ -n ${__BAKE_BAKEFILE__} ]]; then
    _bake::abort "Too many Bakefiles!"
  fi

  local input_bakefile
  local absolute_bakefile

  input_bakefile="$1"
  absolute_bakefile="$(realpath "${input_bakefile}" 2>/dev/null || true)"

  __BAKE_BAKEFILE__="${absolute_bakefile:-"${input_bakefile}"}"
}
