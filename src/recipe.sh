#!/bin/bash

# FIXME:
#   - [OK] bake::recipe::invoke e2e
#   - [OK] bake::recipe::invoke e2e --tags=@todo
#   - [KO] bake::recipe::invoke 'e2e --tags=@todo'
#   - [KO] bake::recipe::invoke e2e --tags='@todo or @fixme'
#   - [OK] bake::recipe::invoke e2e '--tags="@todo or @fixme"
#
#   Make this private and make bake::invoke that behaves just like cli:
#     - bake::invoke e2e
#     - bake::invoke 'e2e --tags=@todo'
#     - bake::invoke 'e2e --tags="@todo or @fixme"'
bake::recipe::invoke() {
  local recipe="$1"
  local args=("${@:2}")

  local recipe_with_args="${recipe}${args+" ${args[*]}"}"

  bake::recipes::include "${recipe}" || bake::abort "No recipe '${recipe_with_args}'!"

  bake::state::set_invoking "${recipe}"
  bake::recipe::invoke_requirements "${recipe}"

  if ! bake::options::quiet; then
    bake::display::info "${recipe}${args+" ${args[*]}"}" ""
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
  # TODO: reset set flags
}
