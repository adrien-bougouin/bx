#!/bin/bash
#
# bx installer.
#
# Usage: curl -fsSL "{{DOWNLOAD_HOST}}/install.sh" | bash

BX_VERSION=
BX_DOWNLOAD_HOST=

BX_RELEASE_SHA256SUMS_URL="${BX_DOWNLOAD_HOST}/SHA256SUMS"
BX_RELEASE_TARBALL_NAME="bx_${BX_VERSION}.tar.gz"
BX_RELEASE_TARBALL_URL="${BX_DOWNLOAD_HOST}/${BX_RELEASE_TARBALL_NAME}"

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

  if [[ -z "${BX_VERSION}${BX_DOWNLOAD_HOST}" ]]; then
    error "Invalid install script configuration!"

    return 1
  fi

  local bx_path="${HOME}/.local/opt/bx"

  if [[ -d ${bx_path} ]]; then
    info "bx is already installed at '${bx_path}'!"

    return 0
  fi

  local tmp_path
  local bx_tarball_path
  local bx_tarball_sha256sum

  tmp_path="$(mktemp -d)"
  bx_tarball_path="${tmp_path}/${BX_RELEASE_TARBALL_NAME}"

  # shellcheck disable=SC2064
  trap "rm -rf '${tmp_path}'" EXIT

  info "Downloading bx ${BX_VERSION}..."
  curl -fL --progress-bar "${BX_RELEASE_TARBALL_URL}" -o "${bx_tarball_path}"

  bx_tarball_sha256sum="$(
    curl -fsSL "${BX_RELEASE_SHA256SUMS_URL}" \
      | grep -F "  ./${BX_RELEASE_TARBALL_NAME}"
  )"

  if ! check_checksum "${bx_tarball_path}" "${bx_tarball_sha256sum%%  ./*}"; then
    error "Download corrupted (checksum mismatch), try again!"

    return 1
  fi

  mkdir -p "${bx_path}"
  tar -xzf "${bx_tarball_path}" -C "${bx_path}" --strip-components 1

  info "Installing bx in '${bx_path}'..."
  (cd "${bx_path}" && ./bin/bx -q install)

  info "Done!"
}

install_bx "$@"
