#!/bin/bash

# FIXME:
#   - [OK] bake::recipe::execute e2e
#   - [OK] bake::recipe::execute e2e --tags=@todo
#   - [KO] bake::recipe::execute 'e2e --tags=@todo'
#   - [KO] bake::recipe::execute e2e --tags='@todo or @fixme'
#   - [OK] bake::recipe::execute e2e '--tags="@todo or @fixme"
#
#   Make this private and make bake::execute that behaves just like cli:
#     - bake::execute e2e
#     - bake::execute 'e2e --tags=@todo'
#     - bake::execute 'e2e --tags="@todo or @fixme"'
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
