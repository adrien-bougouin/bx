#!/bin/bash

__BAKE_OPTION_HELP__="${__BAKE_CONSTANT_FALSE__}"
__BAKE_OPTION_LIST__="${__BAKE_CONSTANT_FALSE__}"
__BAKE_OPTION_QUIET__="${__BAKE_CONSTANT_FALSE__}"
__BAKE_OPTION_VERSION__="${__BAKE_CONSTANT_FALSE__}"

_bake::options::help() {
  return "${__BAKE_OPTION_HELP__}"
}

_bake::options::enable_help() {
  __BAKE_OPTION_HELP__="${__BAKE_CONSTANT_TRUE__}"
}

_bake::options::list() {
  return "${__BAKE_OPTION_LIST__}"
}

_bake::options::enable_list() {
  __BAKE_OPTION_LIST__="${__BAKE_CONSTANT_TRUE__}"
}

_bake::options::quiet() {
  return "${__BAKE_OPTION_QUIET__}"
}

_bake::options::enable_quiet() {
  __BAKE_OPTION_QUIET__="${__BAKE_CONSTANT_TRUE__}"
}

_bake::options::version() {
  return "${__BAKE_OPTION_VERSION__}"
}

_bake::options::enable_version() {
  __BAKE_OPTION_VERSION__="${__BAKE_CONSTANT_TRUE__}"
}
