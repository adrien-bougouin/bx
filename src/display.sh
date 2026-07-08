#!/bin/bash
#
# Display utilities for info and error messaging with consistent formatting
# across the bake tool. Messages are prefixed with a bold topic label that
# defaults to the command name.

################################################################################
# Print an error message to stderr.
#
# Usage:
#   bake::display::error [topic] message
#
# Arguments:
#   topic   - Topic label. If omitted, defaults to the command name.
#   message - The message text.
#
# Outputs:
#   Writes formatted message to stderr.
################################################################################
bake::display::error() {
  bake::display::_stdout "$@" >&2
}

################################################################################
# Print an info message to stdout.
#
# Usage:
#   bake::display::info [topic] message
#
# Arguments:
#   topic   - Topic label. If omitted, defaults to the command name.
#   message - The message text.
#
# Outputs:
#   Writes formatted message to stdout.
################################################################################
bake::display::info() {
  bake::display::_stdout "$@"
}

################################################################################
# Format and print a message with an optional bold topic prefix.
#
# Usage:
#   bake::display::_stdout [topic] message
#
# Globals:
#   __BAKE_CONSTANT_COMMAND_NAME__ - used as default topic when no topic is
#                                    provided.
#
# Arguments:
#   topic   - Topic label. If omitted, defaults to the command name.
#   message - The message text.
#
# Outputs:
#   Writes formatted message to stdout.
################################################################################
bake::display::_stdout() {
  local topic
  local message

  local formatted_topic
  local separator

  if [[ $# -ge 2 ]]; then
    topic="$1"
    message="$2"
  else
    message="$1"
  fi

  if [[ -z ${topic:-} ]]; then
    topic="${__BAKE_CONSTANT_COMMAND_NAME__}"
  fi

  if [[ -n ${topic} ]] && [[ -n ${message} ]]; then
    formatted_topic="$(bake::term::style::bold)${topic}:$(bake::term::style::clear)" \
    separator=" "
  else
    formatted_topic="$(bake::term::style::bold)${topic}$(bake::term::style::clear)" \
    separator=""
  fi

  printf "%s%s%s\n" "${formatted_topic}" "${separator}" "${message}"
}
