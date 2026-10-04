#!/bin/bash
#
# bx uninstaller.
#
# Usage: curl -fsSL "{{DOWNLOAD_HOST}}/uninstall.sh" | bash

DISPLAY_STYLE_NORMAL=
DISPLAY_STYLE_BOLD=

if [[ "$(command -v tput)" ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
  DISPLAY_STYLE_NORMAL="$(tput sgr0)"
  DISPLAY_STYLE_BOLD="$(tput bold)"
fi

info() {
  printf "%s %s\n" \
    "${DISPLAY_STYLE_BOLD}bx-uninstaller:${DISPLAY_STYLE_NORMAL}" \
    "$1"
}

error() {
  printf "%s %s\n" \
    "${DISPLAY_STYLE_BOLD}bx-uninstaller:${DISPLAY_STYLE_NORMAL}" \
    "$1" \
    >&2
}

uninstall_bx() {
  set -euo pipefail

  local bx_path

  if ! command -v bx &>/dev/null; then
    info "bx is not installed!"

    return 0
  fi

  bx_path="$(dirname "$(dirname "$(realpath "$(command -v bx)")")")"

  if [[ $(basename "${bx_path}") != "bx" ]]; then
    error "Cannot find the bx installation directory!"

    return 1
  fi

  info "Uninstalling bx from '${bx_path}'..."
  (cd "${bx_path}" && ./bin/bx -q uninstall)
  rm -rf "${bx_path}"

  info "Done!"
}

uninstall_bx "$@"
