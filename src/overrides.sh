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
#   - Optional leading `--no-exit` flag to return the failure status instead of
#     exiting.
#   - The builtin's name followed by its arguments (e.g. `set -o pipefail`).
#
# Side effects:
#   - Suppresses the builtin's stderr.
#   - Exits with the builtin's status on failure, unless `--no-exit` is given,
#     in which case the status is returned to the caller.
################################################################################
_bx::overrides::execute_builtin_as_caller() {
  if [[ ${BASH_SOURCE[1]-} != "${__BX_OVERRIDES_PATH__}/"* ]]; then
    _bx::abort "internal error: ${FUNCNAME[0]} must be called from an override!"
  fi

  local can_exit="${__BOOL_TRUE__}"
  local caller_source="${BASH_SOURCE[2]}"
  local caller_lineno="${BASH_LINENO[1]}"

  if [[ $1 == --no-exit ]]; then
    can_exit="${__BOOL_FALSE__}"

    shift
  fi

  local builtin_status=0
  if ! { builtin "$@" 2>/dev/null || { builtin_status="$?" && false; }; }; then
    printf "%s: line %d: %s: invalid usage\n" \
      "${caller_source}" \
      "${caller_lineno}" \
      "$*" \
      >&2

    if [[ ${can_exit} == "${__BOOL_TRUE__}" ]]; then
      exit "${builtin_status}"
    else
      return "${builtin_status}"
    fi
  fi
}

source "${__BX_OVERRIDES_PATH__}/set.sh"
source "${__BX_OVERRIDES_PATH__}/trap.sh"
