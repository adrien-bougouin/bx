#!/bin/bash

__BAKE_OPTION_HELP__="${__BAKE_CONSTANT_FALSE__}"
__BAKE_OPTION_QUIET__="${__BAKE_CONSTANT_FALSE__}"

bake::options::help() {
  return "${__BAKE_OPTION_HELP__}"
}

bake::options::enable_help() {
  __BAKE_OPTION_HELP__="${__BAKE_CONSTANT_TRUE__}"
}

bake::options::quiet() {
  return "${__BAKE_OPTION_QUIET__}"
}

bake::options::enable_quiet() {
  __BAKE_OPTION_QUIET__="${__BAKE_CONSTANT_TRUE__}"
}
