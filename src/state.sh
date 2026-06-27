#!/bin/bash

__BAKE_STATE_CONSTANT_INITIALIZING__="initializing"
__BAKE_STATE_CONSTANT_PARSING__="parsing"
__BAKE_STATE_CONSTANT_EXECUTING__="executing"

readonly __BAKE_STATE_CONSTANT_INITIALIZING__
readonly __BAKE_STATE_CONSTANT_PARSING__
readonly __BAKE_STATE_CONSTANT_EXECUTING__

__BAKE_STATE_PROGRESS_STATUS__=${__BAKE_STATE_CONSTANT_INITIALIZING__}
__BAKE_STATE_CURRENT_RECIPE__=""

bake::_state::_set_parsing() {
  __BAKE_STATE_PROGRESS_STATUS__=${__BAKE_STATE_CONSTANT_PARSING__}
  __BAKE_STATE_CURRENT_RECIPE__=$1
}

bake::_state::_set_executing() {
  __BAKE_STATE_PROGRESS_STATUS__=${__BAKE_STATE_CONSTANT_EXECUTING__}
  __BAKE_STATE_CURRENT_RECIPE__=$1
}

bake::_state::_is_parsing() {
  [[ ${__BAKE_STATE_PROGRESS_STATUS__} == "${__BAKE_STATE_CONSTANT_PARSING__}" ]] && return "${__BAKE_CONSTANT_TRUE__}"

  return "${__BAKE_CONSTANT_FALSE__}"
}

bake::_state::_is_executing() {
  [[ ${__BAKE_STATE_PROGRESS_STATUS__} == "${__BAKE_STATE_CONSTANT_EXECUTING__}" ]] && return "${__BAKE_CONSTANT_TRUE__}"

  return "${__BAKE_CONSTANT_FALSE__}"
}

bake::_state::_current_recipe() {
  printf "%s" "${__BAKE_STATE_CURRENT_RECIPE__}"
}
