#!/bin/bash
#
# Domain Specific Language to be used within Bakefile.

################################################################################
# Invoke a recipe from another recipe. Reset shell options before invocation,
# ensuring consistent behavior whether invoked standalone or from another
# recipe. Restore the shell options afterward, so the invoking recipe can
# continue execution with its original settings.
#
# Shell options are reset inside `{ ... } 2>/dev/null` to suppress Bake
# internals' xtrace output if the invoking recipe had `set -x` enabled.
#
# Globals:
#   $- - Current shell options, used to save and restore state.
#
# Arguments:
#   recipe - The recipe name to invoke.
#   args   - Additional arguments forwarded to the recipe.
################################################################################
bake::invoke() {
  {
    local shopts="$-"

    _bake::utils::shell::reset_options
  } 2>/dev/null

  _bake::recipes::invoke "$@"

  _bake::utils::shell::restore_options "${shopts}"
}
