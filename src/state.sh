#!/bin/bash
# TODO: change to annotation_state.sh (or recipes/annotation_state.sh)

__BAKE_STATE_CONSTANT_INITIALIZING__="initializing"
__BAKE_STATE_CONSTANT_PARSING__="parsing"
__BAKE_STATE_CONSTANT_INVOKING__="invoking"

readonly __BAKE_STATE_CONSTANT_INITIALIZING__
readonly __BAKE_STATE_CONSTANT_PARSING__
readonly __BAKE_STATE_CONSTANT_INVOKING__

__BAKE_STATE_CURRENT_RECIPE__=""
__BAKE_STATE_PROGRESS_STATUS__="${__BAKE_STATE_CONSTANT_INITIALIZING__}"

bake::state::current_recipe() {
  printf "%s" "${__BAKE_STATE_CURRENT_RECIPE__}"
}

bake::state::set_parsing() {
  __BAKE_STATE_PROGRESS_STATUS__="${__BAKE_STATE_CONSTANT_PARSING__}"
  __BAKE_STATE_CURRENT_RECIPE__="$1"
}

bake::state::set_invoking() {
  __BAKE_STATE_PROGRESS_STATUS__="${__BAKE_STATE_CONSTANT_INVOKING__}"
  __BAKE_STATE_CURRENT_RECIPE__="$1"
}

bake::state::is_parsing() {
  [[ ${__BAKE_STATE_PROGRESS_STATUS__} == "${__BAKE_STATE_CONSTANT_PARSING__}" ]] && return "${__BAKE_CONSTANT_TRUE__}"

  return "${__BAKE_CONSTANT_FALSE__}"
}

bake::state::is_invoking() {
  [[ ${__BAKE_STATE_PROGRESS_STATUS__} == "${__BAKE_STATE_CONSTANT_INVOKING__}" ]] && return "${__BAKE_CONSTANT_TRUE__}"

  return "${__BAKE_CONSTANT_FALSE__}"
}
