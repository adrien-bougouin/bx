#!/usr/bin/env bash

_bx::uninstall::main() {
  set -euo pipefail

  local __BX_PATH__
  local __BX_SRC_PATH__

  __BX_SRC_PATH__="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
  __BX_PATH__="$(dirname "${__BX_SRC_PATH__}")"

  readonly __BX_PATH__
  readonly __BX_SRC_PATH__

  source "${__BX_SRC_PATH__}/constants.sh"
  source "${__BX_SRC_PATH__}/display.sh"

  ##############################################################################

  local __BX_DISPLAY_PREFIX__="{{bold}}${__BX_CONSTANT_COMMAND_NAME__}-uninstall:{{normal}}"

  readonly __BX_DISPLAY_PREFIX__

  if [[ ! -f "${__BX_PATH__}/Bashfile" ]]; then
    _bx::display::error \
      "${__BX_DISPLAY_PREFIX__} Cannot confirm the installation of bx at '${__BX_PATH__}'!"

    return 1
  fi

  _bx::display::info \
    "${__BX_DISPLAY_PREFIX__} Uninstalling bx from '${__BX_PATH__}'..."

  (cd "${__BX_PATH__}" && ./bin/bx -q -y uninstall)
  rm -rf "${__BX_PATH__}"

  _bx::display::info "${__BX_DISPLAY_PREFIX__} Done!"
}

_bx::uninstall::main "$@"
