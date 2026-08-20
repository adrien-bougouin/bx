#!/bin/bash
#
# Bake installer.
#
# Usage: curl -sSL "https://<host>/install.sh" | bash

BAKE_VERSION=
BAKE_TARBALL_URL=
BAKE_TARBALL_SHA256=

DISPLAY_STYLE_NORMAL=
DISPLAY_STYLE_BOLD=

if [[ "$(command -v tput)" ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
  DISPLAY_STYLE_NORMAL="$(tput sgr0)"
  DISPLAY_STYLE_BOLD="$(tput bold)"
fi

info() {
  printf "%s %s\n" \
    "${DISPLAY_STYLE_BOLD}bake-installer:${DISPLAY_STYLE_NORMAL}" \
    "$1"
}

error() {
  printf "%s %s\n" \
    "${DISPLAY_STYLE_BOLD}bake-installer:${DISPLAY_STYLE_NORMAL}" \
    "$1" \
    >&2
}

checksum() {
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

install_bake() {
  set -euo pipefail

  if [[ -z "${BAKE_VERSION}${BAKE_TARBALL_URL}${BAKE_TARBALL_SHA256}" ]]; then
    error "Invalid install script configuration!"
    exit 1
  fi

  local bake_path="${HOME}/.local/opt/bake_${BAKE_VERSION}"

  if [[ -d ${bake_path} ]]; then
    info "bake ${BAKE_VERSION} is already installed!"
    exit 0
  fi

  local tmp_path
  local bake_tarball_path

  tmp_path="$(mktemp -d)"
  bake_tarball_path="${tmp_path}/bake_${BAKE_VERSION}.tar.gz"

  # shellcheck disable=SC2064
  trap "rm -rf '${tmp_path}'" EXIT

  info "Downloading bake ${BAKE_VERSION}..."
  curl -L --progress-bar "${BAKE_TARBALL_URL}" -o "${bake_tarball_path}"

  if ! checksum "${bake_tarball_path}" "${BAKE_TARBALL_SHA256}"; then
    error "Download corrupted (checksum mismatch), try again!"
    exit 1
  fi

  mkdir -p "${bake_path}"
  tar -xzf "${bake_tarball_path}" -C "${bake_path}" --strip-components 1

  info "Installing bake..."
  (cd "${bake_path}" && ./bin/bake -q install)

  info "Done!"
}

install_bake "$@"
