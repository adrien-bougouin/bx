#!/bin/bash

# initializing, parsing, or executing
__BAKE_PROGRESS_STATUS__=initializing

__BAKE_PROGRESS_RECIPE__=""

bake::progress::set_parsing() {
  __BAKE_PROGRESS_STATUS__=parsing
  __BAKE_PROGRESS_RECIPE__=$1
}

bake::progress::set_executing() {
  __BAKE_PROGRESS_STATUS__=executing
  __BAKE_PROGRESS_RECIPE__=$1
}

bake::progress::recipe() {
  printf "%s" "${__BAKE_PROGRESS_RECIPE__}"
}

bake::progress::is_parsing() {
  if [[ ${__BAKE_PROGRESS_STATUS__} == "parsing" ]]; then
    return 0
  else
    return 1
  fi
}

bake::progress::is_executing() {
  if [[ ${__BAKE_PROGRESS_STATUS__} == "executing" ]]; then
    return 0
  else
    return 1
  fi
}
