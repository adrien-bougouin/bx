#!/bin/bash
#
# bx updater.
#
# Usage: curl -fsSL "{{DOWNLOAD_HOST}}/update.sh" | bash

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
    "${DISPLAY_STYLE_BOLD}bx-updater:${DISPLAY_STYLE_NORMAL}" \
    "$1"
}

error() {
  printf "%s %s\n" \
    "${DISPLAY_STYLE_BOLD}bx-updater:${DISPLAY_STYLE_NORMAL}" \
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

update_bx() {
  set -euo pipefail

  local local_bx_version
  local local_bx_path
  local local_bx_backup_path

  local tmp_path
  local bx_tarball_path
  local bx_swap_path

  if [[ -z "${BX_VERSION}${BX_TARBALL_URL}${BX_TARBALL_SHA256}" ]]; then
    error "Invalid update script configuration!"

    return 1
  fi

  if ! command -v bx &>/dev/null; then
    info "bx is not installed!"

    return 0
  fi

  local_bx_version="$(bx --version | grep -oE "\b[0-9]+\.[0-9]+\.[0-9]+$" || true)"

  if [[ -z ${local_bx_version} ]]; then
    info "Could not determine the installed bx version, updating anyway..."
  elif [[ ${local_bx_version} == "${BX_VERSION}" ]]; then
    info "bx is already up-to-date!"

    return 0
  fi

  local_bx_path="$(dirname "$(dirname "$(realpath "$(command -v bx)")")")"
  local_bx_backup_path="${local_bx_path}.bkp"
  bx_swap_path="${local_bx_path}.new"

  if [[ $(basename "${local_bx_path}") != "bx" ]]; then
    error "Cannot find the bx installation directory!"

    return 1
  fi

  tmp_path="$(mktemp -d)"
  bx_tarball_path="${tmp_path}/bx_${BX_VERSION}.tar.gz"

  # shellcheck disable=SC2064
  trap "
    if [[ ! -d '${local_bx_path}' ]] && [[ -d '${local_bx_backup_path}' ]]; then
      mv '${local_bx_backup_path}' '${local_bx_path}'
    fi

    rm -rf '${bx_swap_path}'
    rm -rf '${local_bx_backup_path}'
    rm -rf '${tmp_path}'
  " EXIT

  info "Downloading bx ${BX_VERSION}..."
  curl -fL --progress-bar "${BX_TARBALL_URL}" -o "${bx_tarball_path}"

  if ! check_checksum "${bx_tarball_path}" "${BX_TARBALL_SHA256}"; then
    error "Download corrupted (checksum mismatch), try again!"

    return 1
  fi

  info "Updating to bx ${BX_VERSION}..."

  rm -rf "${bx_swap_path}"
  mkdir -p "${bx_swap_path}"
  tar -xzf "${bx_tarball_path}" -C "${bx_swap_path}" --strip-components 1

  rm -rf "${local_bx_backup_path}"
  mv "${local_bx_path}" "${local_bx_backup_path}"
  mv "${bx_swap_path}" "${local_bx_path}"

  info "Done!"
}

update_bx "$@"
