#!/bin/bash
#
# Stack of recipes where annotations are currently being parsed.

__BX_ANNOTATION_PARSING_STACK__=()

################################################################################
# Get the number of recipes under annotation parsing.
#
# Globals:
#   __BX_ANNOTATION_PARSING_STACK__ - Stack where recipes under annotation
#                                     parsing are stored.
#
# Outputs:
#   The number of recipes under annotation parsing.
################################################################################
_bx::annotation_parsing_stack::size() {
  printf "%d" "${#__BX_ANNOTATION_PARSING_STACK__[@]}"
}

################################################################################
# Get the last recipe under annotation parsing.
#
# Globals:
#   __BX_ANNOTATION_PARSING_STACK__ - Stack where recipes under annotation
#                                     parsing are stored.
#
# Outputs:
#   The last recipe under annotation parsing.
################################################################################
_bx::annotation_parsing_stack::last() {
  printf "%s" "${__BX_ANNOTATION_PARSING_STACK__[${#__BX_ANNOTATION_PARSING_STACK__[@]} - 1]}"
}

################################################################################
# Add a recipe to the stack of recipes under annotation parsing.
#
# Globals:
#   __BX_ANNOTATION_PARSING_STACK__ - Stack where the recipe is stored.
#
# Arguments:
#   recipe - The recipe to add.
################################################################################
_bx::annotation_parsing_stack::push() {
  __BX_ANNOTATION_PARSING_STACK__+=("$1")
}

################################################################################
# Remove the last recipe from the stack of recipes under annotation parsing.
#
# Globals:
#   __BX_ANNOTATION_PARSING_STACK__ - Stack where the last recipe under
#                                     annotation parsing will be removed.
################################################################################
_bx::annotation_parsing_stack::pop() {
  local new_length=$((${#__BX_ANNOTATION_PARSING_STACK__[@]} - 1))

  __BX_ANNOTATION_PARSING_STACK__=("${__BX_ANNOTATION_PARSING_STACK__[@]:0:new_length}")
}
