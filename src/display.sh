#!/bin/bash
#
# Display utilities for info and error messaging with consistent formatting
# across the Bake tool.

__BAKE_DISPLAY_INDENT__="    "

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
# Usage:
#   bake::display::info message
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stdout.
################################################################################
bake::display::info() {
  bake::display::format "$1"
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
# Usage:
#   bake::display::warning message
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stderr.
################################################################################
bake::display::warning() {
  bake::display::format "$1" >&2
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
# Usage:
#   bake::display::error message
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stderr.
################################################################################
bake::display::error() {
  bake::display::format "$1" >&2
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
# Usage:
#   bake::display::trace level message
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
bake::display::trace() {
  local level="$1"
  local trace="$2"

  local xtrace_prefix="${PS4:-+}"
  local xtrace_repeat_character="${xtrace_prefix:0:1}"

  local xtrace_repeated_character=""

  local i
  for ((i = 0; i < level; i++)); do
    xtrace_repeated_character="${xtrace_repeated_character}${xtrace_repeat_character}"
  done

  bake::display::format "${xtrace_repeated_character} # ${trace}" >&2
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
# Usage:
#   bake::display::format message
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stdout.
################################################################################
bake::display::format() {
  local message="$1"

  message="${message//\{\{indent\}\}/${__BAKE_DISPLAY_INDENT__}}"

  message="${message//\{\{bold\}\}/$(bake::term::style::bold)}"
  message="${message//\{\{normal\}\}/$(bake::term::style::clear)}"

  printf "%s$(bake::term::style::clear)\n" "${message}"
}
