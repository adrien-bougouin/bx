#!/usr/bin/env bash
#
# Builtins overrides to enforce bx's runtime behavior.

_bx::recipe_registry::register_ignore_patterns "^(set|trap)$"

################################################################################
# Override the `set` builtin to prevent xtrace output when bx executes with
# xtrace disabled.
#
# Side effects:
#   - Disables xtrace via `builtin set +x` when `_bx::options::xtrace_enabled`
#     returns false.
#   - On invalid options, reports the caller's source and line, then exits with
#     status 1.
################################################################################
set() {
  local caller_source="${BASH_SOURCE[1]}"
  local caller_lineno="${BASH_LINENO[0]}"

  if ! builtin set "$@" 2>/dev/null; then
    printf "%s: line %d: set: \`%s\`: invalid argument(s)\n" \
      "${caller_source}" \
      "${caller_lineno}" \
      "$*" >&2

    exit 1
  fi

  { _bx::options::xtrace_enabled || builtin set +x; } 2>/dev/null
}

# TODO: Documentation
trap() {
  {
    local options_ref

    _bx::utils::shell::current_options options_ref

    _bx::utils::shell::reset_options
  } 2>/dev/null

  local trap_status=0

  local caller_source="${BASH_SOURCE[1]}"
  local caller_lineno="${BASH_LINENO[0]}"

  # TODO: check target signal EXIT too, then the following can be simplified
  if [[ $# -eq 0 || $1 == -l || $1 == -p ]]; then
    # shellcheck disable=SC2064
    builtin trap "$@" 2>/dev/null || trap_status="$?"

    if [[ ${trap_status} -ne 0 ]]; then
      printf "%s: line %d: trap: \`%s\`: invalid argument(s)\n" \
        "${caller_source}" \
        "${caller_lineno}" \
        "$*" >&2
    fi

    _bx::utils::shell::restore_options "${options_ref}"

    {
      if [[ ${trap_status} -ne 0 ]]; then
        exit "${trap_status}"
      fi

      return
    } 2>/dev/null
  fi

  local must_reinstall

  if _bx::exit_trap::installed; then
    builtin trap - EXIT

    must_reinstall="${__BOOL_TRUE__}"
  else
    must_reinstall="${__BOOL_FALSE__}"
  fi

  # shellcheck disable=SC2064
  builtin trap "$@" 2>/dev/null || trap_status="$?"

  if [[ ${trap_status} -ne 0 ]]; then
    printf "%s: line %d: trap: \`%s\`: invalid argument(s)\n" \
      "${caller_source}" \
      "${caller_lineno}" \
      "$*" >&2
  fi

  if [[ ${must_reinstall} == "${__BOOL_TRUE__}" ]]; then
    _bx::exit_trap::reinstall
  fi

  _bx::utils::shell::restore_options "${options_ref}"

  {
    if [[ ${trap_status} -ne 0 ]]; then
      exit "${trap_status}"
    fi
  } 2>/dev/null
}
