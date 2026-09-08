#!/bin/bash
#
# Domain Specific Language to be used within a Bashfile.

################################################################################
# Invoke a recipe from another recipe. Reset shell options before invocation,
# ensuring consistent behavior whether invoked standalone or from another
# recipe. Restore the shell options afterward, so the invoking recipe can
# continue execution with its original settings.
#
# Shell options are reset inside `{ ... } 2>/dev/null` to suppress bx internal's
# xtrace output if the invoking recipe had `set -x` enabled.
#
# Globals:
#   $- - Current shell options, used to save and restore state.
#
# Arguments:
#   recipe - The recipe name to invoke.
#   args   - Additional arguments forwarded to the recipe.
################################################################################
bx::invoke() {
  {
    local shopts="$-"

    _bx::utils::shell::reset_options
  } 2>/dev/null

  local temporary_auto_confirm="${__BX_CONSTANT_FALSE__}"

  if [[ $1 =~ -y|--yes ]]; then
    if ! _bx::options::auto_confirm; then
      temporary_auto_confirm="${__BX_CONSTANT_TRUE__}"

      _bx::options::enable_auto_confirm
    fi

    shift
  fi

  while [[ $# -gt 0 ]]; do
    _bx::recipe::invoke "$1"

    shift
  done

  if [[ ${temporary_auto_confirm} == "${__BX_CONSTANT_TRUE__}" ]]; then
    _bx::options::disable_auto_confirm
  fi

  _bx::utils::shell::restore_options "${shopts}"
}
