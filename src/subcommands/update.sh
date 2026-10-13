#!/bin/bash

_bx::update::main() {
  set -euo pipefail

  local __BX_SRC_PATH__

  __BX_SRC_PATH__="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")"

  readonly __BX_SRC_PATH__

  source "${__BX_SRC_PATH__}/constants.sh"
  source "${__BX_SRC_PATH__}/display.sh"

  ##############################################################################

  _bx::update::abort() {
    _bx::display::error "{{bold}}bx-updater:{{normal}} $1"

    exit 1
  }

  _bx::update::latest_version() {
    local api_info

    api_info="$(
      curl \
        -fsSL \
        --proto '=https' \
        "https://api.github.com/repos/adrien-bougouin/bx/releases/latest" \
        | grep -m 1 '"tag_name"'
    )"

    if [[ ${api_info} =~ \"v([0-9]+\.[0-9]+\.[0-9]+)\" ]]; then
      printf "%s" "${BASH_REMATCH[1]}"

      return 0
    fi

    _bx::update::abort "Cannot confirm the latest release version of bx!"
  }

  ##############################################################################

  local current_version
  local latest_version
  local latest_version_updater

  current_version="${__BX_CONSTANT_VERSION__}"
  latest_version="$(_bx::update::latest_version)"

  if [[ ${current_version} == "${latest_version}" ]]; then
    _bx::display::info "{{bold}}bx-updater:{{normal}} bx is already up-to-date!"

    return 0
  fi

  latest_version_updater="https://github.com/adrien-bougouin/bx/releases/download/v${latest_version}/update.sh"

  curl -fsSL --proto '=https' "${latest_version_updater}" | bash
}

_bx::update::main "$@"
