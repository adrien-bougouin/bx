#!/bin/bash
#
# Stack of recipes where annotations are currently being parsed.

__BAKE_ANNOTATION_PARSING_STACK__=()

################################################################################
# Get the number of recipes under annotation parsing.
#
# Globals:
#   __BAKE_ANNOTATION_PARSING_STACK__ - Stack where recipes under annotation
#                                       parsing are stored.
#
# Outputs:
#   The number of recipes under annotation parsing.
################################################################################
bake::annotation_parsing_stack::size() {
  printf "%d" "${#__BAKE_ANNOTATION_PARSING_STACK__[@]}"
}

################################################################################
# Get the last recipe under annotation parsing.
#
# Globals:
#   __BAKE_ANNOTATION_PARSING_STACK__ - Stack where recipes under annotation
#                                       parsing are stored.
#
# Outputs:
#   The last recipe under annotation parsing.
################################################################################
bake::annotation_parsing_stack::last() {
  printf "%s" "${__BAKE_ANNOTATION_PARSING_STACK__[${#__BAKE_ANNOTATION_PARSING_STACK__[@]} - 1]}"
}

################################################################################
# Add a recipe to the stack of recipes under annotation parsing.
#
# Globals:
#   __BAKE_ANNOTATION_PARSING_STACK__ - Stack where the recipe is stored.
#
# Arguments:
#   recipe - The recipe to add.
################################################################################
bake::annotation_parsing_stack::push() {
  __BAKE_ANNOTATION_PARSING_STACK__+=("$1")
}

################################################################################
# Remove the last recipe from the stack of recipes under annotation parsing.
#
# Globals:
#   __BAKE_ANNOTATION_PARSING_STACK__ - Stack where the last recipe under
#                                       annotation parsing will be removed.
################################################################################
bake::annotation_parsing_stack::pop() {
  local new_length=$((${#__BAKE_ANNOTATION_PARSING_STACK__[@]} - 1))

  __BAKE_ANNOTATION_PARSING_STACK__=("${__BAKE_ANNOTATION_PARSING_STACK__[@]:0:new_length}")
}
