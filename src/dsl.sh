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

  _bx::recipes::invoke "$@"

  _bx::utils::shell::restore_options "${shopts}"
}
