#!/usr/bin/env bash

_bx::update::main() {
  set -euo pipefail

  local __BX_PATH__
  local __BX_SRC_PATH__

  __BX_SRC_PATH__="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
  __BX_PATH__="$(dirname "${__BX_SRC_PATH__}")"

  readonly __BX_PATH__
  readonly __BX_SRC_PATH__

  source "${__BX_SRC_PATH__}/utils.sh"
  source "${__BX_SRC_PATH__}/constants.sh"
  source "${__BX_SRC_PATH__}/display.sh"

  ##############################################################################

  local __BX_DISPLAY_PREFIX__="{{bold}}${__BX_CONSTANT_COMMAND_NAME__}-update:{{normal}}"
  local __BX_REPOSITORY__="${__BX_CONSTANT_AUTHOR__}/${__BX_CONSTANT_COMMAND_NAME__}"

  readonly __BX_DISPLAY_PREFIX__
  readonly __BX_REPOSITORY__

  _bx::update::abort() {
    _bx::display::error "${__BX_DISPLAY_PREFIX__} $1"

    exit 1
  }

  _bx::update::latest_version() {
    local api_info

    api_info="$(
      curl \
        -fsSL \
        --proto '=https' \
        "https://api.github.com/repos/${__BX_REPOSITORY__}/releases/latest" \
        | grep -m 1 '"tag_name"'
    )"

    if [[ ${api_info} =~ \"v([0-9]+\.[0-9]+\.[0-9]+)\" ]]; then
      printf "%s" "${BASH_REMATCH[1]}"

      return 0
    fi

    _bx::update::abort "Cannot confirm the latest release version of bx!"
  }

  _bx::update::check_checksum() {
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

  _bx::update::display_changelog() {
    local changelog_path="$1"
    local previous_version="$2"

    if [[ ! -f ${changelog_path} ]]; then
      return 0
    fi

    _bx::display::info ""
    _bx::display::info "# Changelog"

    local passed_changelog_header="${__BOOL_FALSE__}"

    local changelog_line
    while IFS= read -r changelog_line; do
      case ${changelog_line} in
        "## [${previous_version}]"*) break ;;
        "## ["*) passed_changelog_header="${__BOOL_TRUE__}" ;;
      esac

      if [[ ${passed_changelog_header} == "${__BOOL_TRUE__}" ]]; then
        printf "%s\n" "${changelog_line}"
      fi
    done <"${changelog_path}"
  }

  ##############################################################################

  if [[ ! -f "${__BX_PATH__}/Bashfile" ]]; then
    _bx::update::abort "Cannot confirm the installation of bx at '${__BX_PATH__}'!"
  fi

  local local_version
  local latest_version

  local_version="${__BX_CONSTANT_VERSION__}"
  latest_version="$(_bx::update::latest_version)"

  if [[ ${local_version} == "${latest_version}" ]]; then
    _bx::display::info "${__BX_DISPLAY_PREFIX__} bx is already up-to-date!"

    return 0
  fi

  local download_host="https://github.com/${__BX_REPOSITORY__}/releases/download/v${latest_version}"
  local tarball_name="${__BX_CONSTANT_COMMAND_NAME__}_${latest_version}.tar.gz"
  local tarball_url="${download_host}/${tarball_name}"
  local sha256sums_url="${download_host}/SHA256SUMS"

  local local_backup_path="${__BX_PATH__}.bkp"
  local swap_path="${__BX_PATH__}.new"

  local tmp_path
  local tarball_path
  local tarball_sha256sum

  tmp_path="$(mktemp -d)"
  tarball_path="${tmp_path}/${tarball_name}"

  # shellcheck disable=SC2064
  trap "
    if [[ ! -d '${__BX_PATH__}' ]] && [[ -d '${local_backup_path}' ]]; then
      mv '${local_backup_path}' '${__BX_PATH__}'
    fi

    rm -rf '${swap_path}'
    rm -rf '${local_backup_path}'
    rm -rf '${tmp_path}'
  " EXIT

  _bx::display::info "${__BX_DISPLAY_PREFIX__} Downloading bx ${latest_version}..."
  curl -fL --proto '=https' --progress-bar "${tarball_url}" -o "${tarball_path}"

  tarball_sha256sum="$(
    curl -fsSL --proto '=https' "${sha256sums_url}" \
      | grep -F "  ./${tarball_name}"
  )"

  if [[ -z ${tarball_sha256sum} ]] \
    || ! _bx::update::check_checksum "${tarball_path}" "${tarball_sha256sum%%  ./*}"; then
    _bx::update::abort "Download corrupted (checksum mismatch), try again!"
  fi

  _bx::display::info "${__BX_DISPLAY_PREFIX__} Updating to bx ${latest_version} in '${__BX_PATH__}'..."

  rm -rf "${swap_path}"
  mkdir -p "${swap_path}"
  tar -xzf "${tarball_path}" -C "${swap_path}" --strip-components 1

  rm -rf "${local_backup_path}"
  mv "${__BX_PATH__}" "${local_backup_path}"
  mv "${swap_path}" "${__BX_PATH__}"

  _bx::update::display_changelog \
    "${__BX_PATH__}/CHANGELOG.md" \
    "${local_version}" \
    || true

  _bx::display::info "${__BX_DISPLAY_PREFIX__} Done!"
}

_bx::update::main "$@"
