#!/bin/bash

bake::recipe::execute() {
  local recipe="$1"
  local args=("${@:2}")

  local recipe_with_args="${recipe}${args+" ${args[*]}"}"

  bake::recipes::include "${recipe}" || bake::abort "No recipe '${recipe_with_args}'!"

  bake::_state::_set_executing "${recipe}"
  bake::recipe::_execute_requirements "${recipe}"

  if ! bake::options::quiet; then
    bake::display::info "${recipe}${args+" ${args[*]}"}" ""
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
  # TODO: reset set flags
}
