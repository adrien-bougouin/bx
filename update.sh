
#!/bin/bash
#
# bx installer.
#
# Usage: curl -fsSL "{{DOWNLOAD_HOST}}/install.sh" | bash

# TODO: Have `bx dist` (see Bashfile) set those rhree after copying to dist
#       directory.
BX_VERSION=
BX_TARBALL_URL=
BX_TARBALL_SHA256=

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

update_bx() {
  set -euo pipefail

  if [[ -z "${BX_VERSION}${BX_TARBALL_URL}${BX_TARBALL_SHA256}" ]]; then
    error "Invalid update script configuration!"

    return 1
  fi

  if ! command -v bx &>/dev/null; then
    error "bx is not installed!"

    return 1
  fi

  if [[ $(bx --version | grep -oE "\b[0-9]+\.[0-9]+\.[0-9]+$") == "${BX_VERSION}" ]]; then
    info "bx is already up-to-date!"

    return 0
  fi

  # TODO:
  #   1. Download "${BX_TARBALL_URL}" to temp file
  #   2. Check tarball checksum (${BX_TARBALL_SHA256})
  #   3. Replace current bx installed directory with tarball content

  info "Done!"
}

update_bx "$@"
