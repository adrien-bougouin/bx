#!/bin/bash

__BAKE_TRACE_INVOCATION_LEVEL__=1

bake::trace::invocation_level() {
  printf "%d" "${__BAKE_TRACE_INVOCATION_LEVEL__}"
}

bake::trace::invocation_prefix() {
  local repeat_character="${PS4:0:1}"

  local repeated_character=""

  local i
  for ((i = 1; i <= __BAKE_TRACE_INVOCATION_LEVEL__; i++)); do
    repeated_character="${repeat_character}${repeated_character}"
  done

  printf "%s" "${repeated_character}"
}

bake::trace::increase_invocation_level() {
  __BAKE_TRACE_INVOCATION_LEVEL__=$((__BAKE_TRACE_INVOCATION_LEVEL__ + 1))
}
bake::trace::decrease_invocation_level() {
  __BAKE_TRACE_INVOCATION_LEVEL__=$((__BAKE_TRACE_INVOCATION_LEVEL__ - 1))
}
