#!/bin/bash
#
# Stack of currently invoked recipes.
# The first recipe is a recipe invoked by user. The other recipes are nested
# invocation (recipe at index n+1 was invoked by recipe at index n).

__BX_INVOCATION_STACK__=()

################################################################################
# Get the number of recipes under invocation.
#
# Globals:
#   __BX_INVOCATION_STACK__ - Stack where recipes under invocation are stored.
#
# Outputs:
#   The number of recipes under invocation.
################################################################################
_bx::invocation_stack::size() {
  printf "%d" "${#__BX_INVOCATION_STACK__[@]}"
}

_bx::invocation_stack::includes() {
  [[ ${#__BX_INVOCATION_STACK__[@]} -eq 0 ]] && return "${__BX_CONSTANT_FALSE__}"

  local recipe="$1"

  local invoked_recipe
  for invoked_recipe in "${__BX_INVOCATION_STACK__[@]}"; do
    [[ ${recipe} == "${invoked_recipe}" ]] && return "${__BX_CONSTANT_TRUE__}"
  done

  return "${__BX_CONSTANT_FALSE__}"
}

################################################################################
# Add a recipe to the stack of recipes under invocation.
#
# Globals:
#   __BX_INVOCATION_STACK__ - Stack where the recipe is stored.
#
# Arguments:
#   recipe - The recipe to add.
################################################################################
_bx::invocation_stack::push() {
  __BX_INVOCATION_STACK__+=("$1")
}

################################################################################
# Remove the last recipe from the stack of recipes under invocation.
#
# Globals:
#   __BX_INVOCATION_STACK__ - Stack where the last invoked recipe will be
#                             removed.
################################################################################
_bx::invocation_stack::pop() {
  local new_length=$((${#__BX_INVOCATION_STACK__[@]} - 1))

  __BX_INVOCATION_STACK__=("${__BX_INVOCATION_STACK__[@]:0:new_length}")
}
