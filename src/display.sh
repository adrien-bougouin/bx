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
# Print a trace message to stderr.
#
# Formatting:
#   - {{indent}}: 4 space indentation
#
# Styling:
#   - {{bold}}: following text renders bold (if supported)
#   - {{normal}}: following text style is reset to normal style
#
# Usage:
#   bake::display::trace message
#
# Arguments:
#   message - The message text.
#
# Outputs:
#   Writes the formatted message to stderr.
################################################################################
bake::display::trace() {
  # TODO: handle repeat character here
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
