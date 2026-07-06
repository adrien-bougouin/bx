#!/bin/bash

bake::_annotations::_register "@require:"

@require:() {
  if bake::_state::_is_executing; then
    bake::recipes::execute "$@"
  fi
}
