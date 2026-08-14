#!/bin/bash

__BAKE_TRACE_INVOCATION_LEVEL__=1

bake::trace::invocation_level() {
  printf "%d" "${__BAKE_TRACE_INVOCATION_LEVEL__}"
}

bake::trace::increase_invocation_level() {
  __BAKE_TRACE_INVOCATION_LEVEL__=$((__BAKE_TRACE_INVOCATION_LEVEL__ + 1))
}
bake::trace::decrease_invocation_level() {
  __BAKE_TRACE_INVOCATION_LEVEL__=$((__BAKE_TRACE_INVOCATION_LEVEL__ - 1))
}
