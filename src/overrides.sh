#!/usr/bin/env bash
#
# Builtins overrides to enforce bx's runtime behavior.

__BX_OVERRIDES_PATH__="${__BX_SRC_PATH__}/overrides"

readonly __BX_OVERRIDES_PATH__

################################################################################
# Execute a builtin on behalf of an override, reporting failures relative to
# the caller's source location.
#
# Can only be called directly from a function declared under
# `__BX_OVERRIDES_PATH__`.
#
# Arguments:
#   - The builtin's name followed by its arguments (e.g. `set -o pipefail`).
#
# Side effects:
#   - Suppresses the builtin's stderr.
#   - Exits with status 1 when the builtin fails.
################################################################################
_bx::overrides::execute_builtin() {
  if [[ ${BASH_SOURCE[1]-} != "${__BX_OVERRIDES_PATH__}/"* ]]; then
    _bx::abort "internal error: ${FUNCNAME[0]} must be called from an override!"
  fi

  local caller_source="${BASH_SOURCE[2]}"
  local caller_lineno="${BASH_LINENO[1]}"

  if ! builtin "$@" 2>/dev/null; then
    printf "%s: line %d: %s: invalid usage\n" \
      "${caller_source}" \
      "${caller_lineno}" \
      "$*" \
      >&2

    exit 1
  fi
}

source "${__BX_OVERRIDES_PATH__}/set.sh"
