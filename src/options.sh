#!/usr/bin/env bash

__BX_OPTION_HELP__="${__BOOL_FALSE__}"
__BX_OPTION_LIST__="${__BOOL_FALSE__}"
__BX_OPTION_VERSION__="${__BOOL_FALSE__}"

__BX_OPTION_RECIPE_TRACING__="${__BOOL_TRUE__}"
__BX_OPTION_XTRACING__="${__BOOL_TRUE__}"

__BX_OPTION_AUTO_CONFIRM__="${__BOOL_FALSE__}"

_bx::options::help() {
  return "${__BX_OPTION_HELP__}"
}

_bx::options::enable_help() {
  __BX_OPTION_HELP__="${__BOOL_TRUE__}"
}

_bx::options::list() {
  return "${__BX_OPTION_LIST__}"
}

_bx::options::enable_list() {
  __BX_OPTION_LIST__="${__BOOL_TRUE__}"
}

_bx::options::version() {
  return "${__BX_OPTION_VERSION__}"
}

_bx::options::enable_version() {
  __BX_OPTION_VERSION__="${__BOOL_TRUE__}"
}

_bx::options::recipe_tracing() {
  return "${__BX_OPTION_RECIPE_TRACING__}"
}

_bx::options::disable_recipe_tracing() {
  __BX_OPTION_RECIPE_TRACING__="${__BOOL_FALSE__}"
}

_bx::options::xtracing() {
  return "${__BX_OPTION_XTRACING__}"
}

_bx::options::disable_xtracing() {
  __BX_OPTION_XTRACING__="${__BOOL_FALSE__}"
}

_bx::options::auto_confirm() {
  return "${__BX_OPTION_AUTO_CONFIRM__}"
}

_bx::options::enable_auto_confirm() {
  __BX_OPTION_AUTO_CONFIRM__="${__BOOL_TRUE__}"
}

_bx::options::disable_auto_confirm() {
  __BX_OPTION_AUTO_CONFIRM__="${__BOOL_FALSE__}"
}
