#!/bin/bash

__BX_BASHFILE__=

_bx::load_bashfile() {
  if [[ -z ${__BX_BASHFILE__} ]]; then
    local lookup_path="${__BX_WORKING_DIRECTORY__}"

    while [[ ${lookup_path} != "/" ]] && [[ -z ${__BX_BASHFILE__} ]]; do
      local bashfile_candidate="${lookup_path}/Bashfile"

      [[ -f ${bashfile_candidate} ]] && _bx::set_bashfile "${bashfile_candidate}"

      lookup_path="$(dirname "${lookup_path}")"
    done
  fi

  readonly __BX_BASHFILE__

  if [[ -f ${__BX_BASHFILE__} ]]; then
    source "${__BX_BASHFILE__}"
  else
    _bx::abort "No Bashfile!"
  fi
}

_bx::set_bashfile() {
  if [[ -n ${__BX_BASHFILE__} ]]; then
    _bx::abort "Too many Bashfiles!"
  fi

  local input_bashfile
  local absolute_bashfile

  input_bashfile="$1"
  absolute_bashfile="$(realpath "${input_bashfile}" 2>/dev/null || true)"

  __BX_BASHFILE__="${absolute_bashfile:-"${input_bashfile}"}"
}
