#!/bin/bash
#
# bx installer.
#
# Usage: curl -fsSL "{{DOWNLOAD_HOST}}/install.sh" | bash

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

check_checksum() {
  local filepath="$1"
  local file_sha="$2"

  local shasum_cmd

  if command -v sha256sum >/dev/null 2>&1; then
    shasum_cmd="sha256sum"
  else
    shasum_cmd="shasum -a 256"
  fi

  printf "%s  %s" "${file_sha}" "${filepath}" | ${shasum_cmd} -c - >/dev/null
}

install_bx() {
  set -euo pipefail

  if [[ -z "${BX_VERSION}${BX_TARBALL_URL}${BX_TARBALL_SHA256}" ]]; then
    error "Invalid install script configuration!"
    exit 1
  fi

  local bx_path="${HOME}/.local/opt/bx_${BX_VERSION}"

  if [[ -d ${bx_path} ]]; then
    info "bx ${BX_VERSION} is already installed!"
    exit 0
  fi

  local tmp_path
  local bx_tarball_path

  tmp_path="$(mktemp -d)"
  bx_tarball_path="${tmp_path}/bx_${BX_VERSION}.tar.gz"

  # shellcheck disable=SC2064
  trap "rm -rf '${tmp_path}'" EXIT

  info "Downloading bx ${BX_VERSION}..."
  curl -fL --progress-bar "${BX_TARBALL_URL}" -o "${bx_tarball_path}"

  if ! check_checksum "${bx_tarball_path}" "${BX_TARBALL_SHA256}"; then
    error "Download corrupted (checksum mismatch), try again!"
    exit 1
  fi

  mkdir -p "${bx_path}"
  tar -xzf "${bx_tarball_path}" -C "${bx_path}" --strip-components 1

  info "Installing bx..."
  # TODO: revert to "./bin/bx" when the file is renamed.
  (cd "${bx_path}" && ./bin/bake -q install)

  info "Done!"
}

install_bx "$@"
