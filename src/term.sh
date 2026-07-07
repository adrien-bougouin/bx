#!/bin/bash

__BAKE_TERM_STYLE_CLEAR__=""
__BAKE_TERM_STYLE_BOLD__=""

__BAKE_TERM_STYLE_RED_FG__=""
__BAKE_TERM_STYLE_GREEN_FG__=""
__BAKE_TERM_STYLE_YELLOW_FG__=""

# BASH unset ${TERM} value is 'dumb'!
if [[ "$(command -v tput)" ]] && [[ ${TERM:-dumb} != "dumb" ]]; then
  __BAKE_TERM_STYLE_CLEAR__="$(tput sgr0)"
  __BAKE_TERM_STYLE_BOLD__="$(tput bold)"

  __BAKE_TERM_STYLE_RED_FG__="$(tput setaf 1)"
  __BAKE_TERM_STYLE_GREEN_FG__="$(tput setaf 2)"
  __BAKE_TERM_STYLE_YELLOW_FG__="$(tput setaf 3)"
fi

readonly __BAKE_TERM_STYLE_CLEAR__
readonly __BAKE_TERM_STYLE_BOLD__

readonly __BAKE_TERM_STYLE_RED_FG__
readonly __BAKE_TERM_STYLE_GREEN_FG__
readonly __BAKE_TERM_STYLE_YELLOW_FG__

bake::term::style::clear() {
  printf "%s" "${__BAKE_TERM_STYLE_CLEAR__}"
}

bake::term::style::bold() {
  printf "%s" "${__BAKE_TERM_STYLE_BOLD__}"
}

bake::term::style::red_fg() {
  printf "%s" "${__BAKE_TERM_STYLE_RED_FG__}"
}

bake::term::style::green_fg() {
  printf "%s" "${__BAKE_TERM_STYLE_GREEN_FG__}"
}

bake::term::style::yellow_fg() {
  printf "%s" "${__BAKE_TERM_STYLE_YELLOW_FG__}"
}
