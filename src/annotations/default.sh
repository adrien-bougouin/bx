#!/bin/bash

__BX_RECIPE_DEFAULT__=""

_bx::annotations::register "@default"

@default() {
  if [[ $(_bx::annotation_parsing_stack::size) -gt 0 ]]; then
    if [[ -n "$(_bx::recipes::default)" ]]; then
      _bx::abort "Too many default recipes!"
    fi

    __BX_RECIPE_DEFAULT__="$(_bx::annotation_parsing_stack::last)"
  fi
}

_bx::recipes::default() {
  printf "%s" "${__BX_RECIPE_DEFAULT__}"
}
