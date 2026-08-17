#!/bin/bash
#
# Stack of currently invoked recipes.
# The first recipe is a recipe invoked by user. The other recipes are nested
# invocation (recipe at index n+1 was invoked by recipe at index n).

__BAKE_INVOCATION_STACK__=()

################################################################################
# Get the number of recipes under invocation.
#
# Globals:
#   __BAKE_INVOCATION_STACK__ - Stack where recipes under invocation are stored.
#
# Outputs:
#   The number of recipes under invocation.
################################################################################
bake::invocation_stack::size() {
  printf "%d" "${#__BAKE_INVOCATION_STACK__[@]}"
}

################################################################################
# Add a recipe to the stack of recipes under invocation.
#
# Globals:
#   __BAKE_INVOCATION_STACK__ - Stack where the recipe is stored.
#
# Arguments:
#   recipe - The recipe to add.
################################################################################
bake::invocation_stack::push() {
  __BAKE_INVOCATION_STACK__+=("$1")
}

################################################################################
# Remove the last recipe the stack of recipes under invocation.
#
# Globals:
#   __BAKE_INVOCATION_STACK__ - Stack where the last invoked recipe must be
#                               removed.
################################################################################
bake::invocation_stack::pop() {
  local new_length=$((${#__BAKE_INVOCATION_STACK__[@]} - 1))

  __BAKE_INVOCATION_STACK__=("${__BAKE_INVOCATION_STACK__[@]:0:new_length}")
}
