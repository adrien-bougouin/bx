#!/bin/bash

__BAKE_RECIPE_DEFAULT__=""

_bake::annotations::register "@default"

@default() {
  if [[ $(_bake::annotation_parsing_stack::size) -gt 0 ]]; then
    if [[ -n "$(_bake::recipes::default)" ]]; then
      _bake::abort "Too many default recipes!"
    fi

    _bake::recipes::set_default "$(_bake::annotation_parsing_stack::last)"
  fi
}

_bake::recipes::default() {
  printf "%s" "${__BAKE_RECIPE_DEFAULT__}"
}

_bake::recipes::set_default() {
  if [[ $# -gt 1 ]]; then
    _bake::abort "Too many default recipes!"
  fi

  __BAKE_RECIPE_DEFAULT__="$1"
}
