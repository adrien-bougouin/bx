#!/bin/bash
#
# Display utilities for info and error messaging with consistent formatting
# across the Bake tool.

__BAKE_DISPLAY_INDENT__="    "

__BAKE_DISPLAY_STYLE_NORMAL__=""
__BAKE_DISPLAY_STYLE_BOLD__=""

# BASH unset ${TERM} value is 'dumb'!
if [[ "$(command -v tput)" ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
  __BAKE_DISPLAY_STYLE_NORMAL__="$(tput sgr0)"
  __BAKE_DISPLAY_STYLE_BOLD__="$(tput bold)"
fi

readonly __BAKE_DISPLAY_INDENT__

readonly __BAKE_DISPLAY_STYLE_NORMAL__
readonly __BAKE_DISPLAY_STYLE_BOLD__

################################################################################
# Print an info message to stdout.
#
# Formatting:
#   - {{indent}}: 4 space indentation
#
# Styling:
#   - {{bold}}: following text renders bold (if supported)
#   - {{normal}}: following text style is reset to normal style
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stdout.
################################################################################
_bake::display::info() {
  _bake::display::format "$1"
}

################################################################################
# Print a warning message to stderr.
#
# Formatting:
#   - {{indent}}: 4 space indentation
#
# Styling:
#   - {{bold}}: following text renders bold (if supported)
#   - {{normal}}: following text style is reset to normal style
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stderr.
################################################################################
_bake::display::warning() {
  _bake::display::format "$1" >&2
}

################################################################################
# Print an error message to stderr.
#
# Formatting:
#   - {{indent}}: 4 space indentation
#
# Styling:
#   - {{bold}}: following text renders bold (if supported)
#   - {{normal}}: following text style is reset to normal style
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stderr.
################################################################################
_bake::display::error() {
  _bake::display::format "$1" >&2
}

################################################################################
# Print a trace message to stderr.
#
# The trace formatting is consistent with xtrace's repeat character, and is
# designed to not cause issues if user wants to replay the traces.
#
# Formatting:
#   - {{indent}}: 4 space indentation
#
# Styling:
#   - {{bold}}: following text renders bold (if supported)
#   - {{normal}}: following text style is reset to normal style
#
# Arguments:
#   level   - The invocation level of the calling function/recipe.
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stderr.
#   For instance, with PS4='+ ':
#     + # <message-of-level-1>
#     ++ # <message-of-level-2>
################################################################################
_bake::display::trace() {
  local level="$1"
  local trace="$2"

  local xtrace_prefix="${PS4:-+}"
  local xtrace_repeat_character="${xtrace_prefix:0:1}"

  local xtrace_repeated_character=""

  local i
  for ((i = 0; i < level; i++)); do
    xtrace_repeated_character="${xtrace_repeated_character}${xtrace_repeat_character}"
  done

  _bake::display::format "${xtrace_repeated_character} # ${trace}" >&2
}

################################################################################
# Format and print a message.
#
# Formatting:
#   - {{indent}}: 4 space indentation
#
# Styling:
#   - {{bold}}: following text renders bold (if supported)
#   - {{normal}}: following text style is reset to normal style
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stdout.
################################################################################
_bake::display::format() {
  local message="$1"

  message="${message//\{\{indent\}\}/${__BAKE_DISPLAY_INDENT__}}"

  message="${message//\{\{normal\}\}/${__BAKE_DISPLAY_STYLE_NORMAL__}}"
  message="${message//\{\{bold\}\}/${__BAKE_DISPLAY_STYLE_BOLD__}}"

  printf "%s${__BAKE_DISPLAY_STYLE_NORMAL__}\n" "${message}"
}
