#!/bin/bash
#
# Display utilities for info and error messaging with consistent formatting
# across the bake tool.

__BAKE_DISPLAY_INDENT__="    "

################################################################################
# Print an error message to stderr.
# The {{indent}} placeholder in the message is replaced with 4 spaces.
#
# Usage:
#   bake::display::error [topic] message
#
# Arguments:
#   topic   - Topic label (optional).
#   message - The message text.
#
# Outputs:
#   Writes formatted message to stderr.
#   When both topic and message are provided:    "bold(topic): message"
#   When topic is provided and message is empty: "bold(topic)"
#   When only message is provided:               "message"
################################################################################
bake::display::error() {
  bake::display::_stdout "$@" >&2
}

################################################################################
# Print an info message to stdout.
# The {{indent}} placeholder in the message is replaced with 4 spaces.
#
# Usage:
#   bake::display::info [topic] message
#
# Arguments:
#   topic   - Topic label (optional).
#   message - The message text.
#
# Outputs:
#   Writes formatted message to stdout.
#   When both topic and message are provided:    "bold(topic): message"
#   When topic is provided and message is empty: "bold(topic)"
#   When only message is provided:               "message"
################################################################################
bake::display::info() {
  bake::display::_stdout "$@"
}

################################################################################
# Format and print a message with an optional bold topic prefix.
# The {{indent}} placeholder in the message is replaced with 4 spaces.
#
# Usage:
#   bake::display::_stdout [topic] message
#
# Arguments:
#   topic   - Topic label (optional).
#   message - The message text.
#
# Outputs:
#   Writes formatted message to stdout.
#   When both topic and message are provided:    "bold(topic): message"
#   When topic is provided and message is empty: "bold(topic)"
#   When only message is provided:               "message"
################################################################################
bake::display::_stdout() {
  local topic
  local message

  if [[ $# -ge 2 ]]; then
    topic="$1"
    message="$2"
  else
    message="$1"
  fi

  local formatted_topic=""
  local separator=""
  local formatted_message="${message//\{\{indent\}\}/${__BAKE_DISPLAY_INDENT__}}"

  if [[ -n ${topic} ]] && [[ -n ${message} ]]; then
    formatted_topic="$(bake::term::style::bold)${topic}:$(bake::term::style::clear)"
    separator=" "
  elif [[ -n ${topic} ]]; then
    formatted_topic="$(bake::term::style::bold)${topic}$(bake::term::style::clear)"
  fi

  printf "%s%s%s\n" "${formatted_topic}" "${separator}" "${formatted_message}"
}
