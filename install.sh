#!/bin/bash
#
# bx installer.
#
# Usage: curl -fsSL "{{__BX_DOWNLOAD_HOST__}}/install.sh" | bash

__BX_VERSION__=
__BX_DOWNLOAD_HOST__=

__BX_SHA256SUMS_URL__="${__BX_DOWNLOAD_HOST__}/SHA256SUMS"
__BX_TARBALL_NAME__="bx_${__BX_VERSION__}.tar.gz"
__BX_TARBALL_URL__="${__BX_DOWNLOAD_HOST__}/${__BX_TARBALL_NAME__}"

__BX_DISPLAY_STYLE_NORMAL__=
__BX_DISPLAY_STYLE_BOLD__=

if [[ "$(command -v tput)" ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
  __BX_DISPLAY_STYLE_NORMAL__="$(tput sgr0)"
  __BX_DISPLAY_STYLE_BOLD__="$(tput bold)"
fi

info() {
  printf "%s %s\n" \
    "${__BX_DISPLAY_STYLE_BOLD__}bx-installer:${__BX_DISPLAY_STYLE_NORMAL__}" \
    "$1"
}

error() {
  printf "%s %s\n" \
    "${__BX_DISPLAY_STYLE_BOLD__}bx-installer:${__BX_DISPLAY_STYLE_NORMAL__}" \
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

  if [[ -z "${__BX_VERSION__}${__BX_DOWNLOAD_HOST__}" ]]; then
    error "Invalid install script configuration!"

    return 1
  fi

  local install_path="${HOME}/.local/opt/bx"

  if [[ -d ${install_path} ]]; then
    info "bx is already installed at '${install_path}'!"

    return 0
  fi

  local tmp_path
  local tarball_path
  local tarball_sha256sum

  tmp_path="$(mktemp -d)"
  tarball_path="${tmp_path}/${__BX_TARBALL_NAME__}"

  # shellcheck disable=SC2064
  trap "rm -rf '${tmp_path}'" EXIT

  info "Downloading bx ${__BX_VERSION__}..."
  curl -fL --progress-bar "${__BX_TARBALL_URL__}" -o "${tarball_path}"

  tarball_sha256sum="$(curl -fsSL "${__BX_SHA256SUMS_URL__}" | grep -F "  ./${__BX_TARBALL_NAME__}")"

  if ! check_checksum "${tarball_path}" "${tarball_sha256sum%%  ./*}"; then
    error "Download corrupted (checksum mismatch), try again!"

    return 1
  fi

  mkdir -p "${install_path}"
  tar -xzf "${tarball_path}" -C "${install_path}" --strip-components 1

  info "Installing bx in '${install_path}'..."
  (cd "${install_path}" && ./bin/bx -q install)

  info "Done!"
}

install_bx "$@"
