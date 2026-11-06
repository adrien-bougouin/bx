#!/usr/bin/env bash
#
# Runtime options controlling bx's behavior.

__BX_OPTION_RECIPE_TRACE__="${__BOOL_TRUE__}"
__BX_OPTION_XTRACE__="${__BOOL_TRUE__}"

__BX_OPTION_AUTO_CONFIRM__="${__BOOL_FALSE__}"

# Allow users to disable recipe traces by default through the environment.
if [[ ${BX_RECIPE_TRACE:-} == "0" ]]; then
  __BX_OPTION_RECIPE_TRACE__="${__BOOL_FALSE__}"
fi

################################################################################
# Check whether recipe-level traces are enabled.
#
# Returns:
#   0 (true) if recipe traces are enabled, 1 (false) otherwise.
################################################################################
_bx::options::recipe_trace_enabled() {
  return "${__BX_OPTION_RECIPE_TRACE__}"
}

################################################################################
# Disable recipe-level traces.
#
# Side effects:
#   Sets __BX_OPTION_RECIPE_TRACE__ to false.
################################################################################
_bx::options::disable_recipe_trace() {
  __BX_OPTION_RECIPE_TRACE__="${__BOOL_FALSE__}"
}

################################################################################
# Check whether xtrace output is enabled.
#
# Returns:
#   0 (true) if xtrace output is enabled, 1 (false) otherwise.
################################################################################
_bx::options::xtrace_enabled() {
  return "${__BX_OPTION_XTRACE__}"
}

################################################################################
# Disable xtrace output.
#
# Side effects:
#   Sets __BX_OPTION_XTRACE__ to false.
################################################################################
_bx::options::disable_xtrace() {
  __BX_OPTION_XTRACE__="${__BOOL_FALSE__}"
}

################################################################################
# Check whether confirmation prompts are automatically accepted.
#
# Returns:
#   0 (true) if confirmations are automatically accepted, 1 (false) otherwise.
################################################################################
_bx::options::auto_confirm_enabled() {
  return "${__BX_OPTION_AUTO_CONFIRM__}"
}

################################################################################
# Enable automatic confirmation.
#
# Side effects:
#   Sets __BX_OPTION_AUTO_CONFIRM__ to true.
################################################################################
_bx::options::enable_auto_confirm() {
  __BX_OPTION_AUTO_CONFIRM__="${__BOOL_TRUE__}"
}

################################################################################
# Disable automatic confirmation.
#
# Side effects:
#   Sets __BX_OPTION_AUTO_CONFIRM__ to false.
################################################################################
_bx::options::disable_auto_confirm() {
  __BX_OPTION_AUTO_CONFIRM__="${__BOOL_FALSE__}"
}
