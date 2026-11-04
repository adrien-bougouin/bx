#!/usr/bin/env bash

__BX_BASHFILE_LOADED__="${__BOOL_FALSE__}"

__BX_BASHFILE_PATH__=

_bx::bashfile::loaded_path() {
  if [[ ${__BX_BASHFILE_LOADED__} == "${__BOOL_FALSE__}" ]]; then
    return
  fi

  printf "%s" "${__BX_BASHFILE_PATH__}"
}

_bx::bashfile::set_path() {
  if [[ -n ${__BX_BASHFILE_PATH__} ]]; then
    _bx::abort "Too many Bashfiles!"
  fi

  local bashfile_directory

  if bashfile_directory="$(CDPATH="" cd "$(dirname "$1")" 2>/dev/null && pwd)"; then
    __BX_BASHFILE_PATH__="${bashfile_directory}/$(basename "$1")"
  else
    __BX_BASHFILE_PATH__="$1"
  fi
}

_bx::bashfile::load() {
  if [[ -z ${__BX_BASHFILE_PATH__} ]]; then
    local lookup_path="${__BX_WORKING_DIRECTORY__}"

    while [[ ${lookup_path} != "/" ]] && [[ -z ${__BX_BASHFILE_PATH__} ]]; do
      local bashfile_candidate="${lookup_path}/Bashfile"

      if [[ -f ${bashfile_candidate} ]]; then
        _bx::bashfile::set_path "${bashfile_candidate}"
      fi

      lookup_path="$(dirname "${lookup_path}")"
    done
  fi

  readonly __BX_BASHFILE_PATH__

  if [[ -f ${__BX_BASHFILE_PATH__} ]]; then
    source "${__BX_BASHFILE_PATH__}"
  else
    _bx::abort "No Bashfile!"
  fi

  __BX_BASHFILE_LOADED__="${__BOOL_TRUE__}"

  readonly __BX_BASHFILE_LOADED__
}
