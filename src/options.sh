#!/bin/bash

__BAKE_OPTION_HELP__=false
__BAKE_OPTION_QUIET__=false

bake::options::help() {
  [[ ${__BAKE_OPTION_HELP__} == true ]] && return 0

  return 1
}

bake::options::enable_help() {
  __BAKE_OPTION_HELP__=true
}

bake::options::quiet() {
  [[ ${__BAKE_OPTION_QUIET__} == true ]] && return 0

  return 1
}

bake::options::enable_quiet() {
  __BAKE_OPTION_QUIET__=true
}
