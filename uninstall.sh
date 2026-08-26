#!/bin/bash
#
# bx installer.
#
# Usage: curl -fsSL "{{DOWNLOAD_HOST}}/uninstall.sh" | bash

BX_VERSION=

DISPLAY_STYLE_NORMAL=
DISPLAY_STYLE_BOLD=

if [[ "$(command -v tput)" ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
  DISPLAY_STYLE_NORMAL="$(tput sgr0)"
  DISPLAY_STYLE_BOLD="$(tput bold)"
fi

info() {
  printf "%s %s\n" \
    "${DISPLAY_STYLE_BOLD}bx-installer:${DISPLAY_STYLE_NORMAL}" \
    "$1"
}

error() {
  printf "%s %s\n" \
    "${DISPLAY_STYLE_BOLD}bx-installer:${DISPLAY_STYLE_NORMAL}" \
    "$1" \
    >&2
}

uninstall_bx() {
  set -euo pipefail

  local bx_path="${HOME}/.local/opt/bx"

  if [[ ! -d ${bx_path} ]]; then
    info "bx ${BX_VERSION} is not installed!"

    return 0
  fi

  info "Uninstalling bx..."
  (cd "${bx_path}" && ./bin/bx -q uninstall)
  rm -rf "${bx_path}"

  info "Done!"
}

uninstall_bx "$@"
