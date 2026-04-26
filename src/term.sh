#!/bin/bash

export __BAKE_TERM_BOLD__=""

export __BAKE_TERM_RED_FG__=""
export __BAKE_TERM_GREEN_FG__=""
export __BAKE_TERM_YELLOW_FG__=""

export __BAKE_TERM_RESET__=""

# BASH unset ${TERM} value is 'dumb'!
if [[ ${TERM:-dumb} != "dumb" ]]; then
  __BAKE_TERM_BOLD__="$(tput bold)"

  __BAKE_TERM_RED_FG__="$(tput setaf 1)"
  __BAKE_TERM_GREEN_FG__="$(tput setaf 2)"
  __BAKE_TERM_YELLOW_FG__="$(tput setaf 3)"

  __BAKE_TERM_RESET__="$(tput sgr0)"
fi

readonly __BAKE_TERM_BOLD__

readonly __BAKE_TERM_RED_FG__
readonly __BAKE_TERM_GREEN_FG__
readonly __BAKE_TERM_YELLOW_FG__

readonly __BAKE_TERM_RESET__
