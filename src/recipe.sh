#!/bin/bash

bake::recipe::execute() {
  local recipe="$1"
  local args=("${@:2}")

  local recipe_with_args="${recipe}${args+" ${args[*]}"}"

  bake::recipes::include "${recipe}" || bake::abort "no recipe '${recipe_with_args}'"

  bake::_state::_set_executing "${recipe}"

  if ! bake::options::quiet; then
    printf "%s%s%s%s\n" \
      "$(bake::term::style::bold)" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "$(bake::term::style::clear)"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
  # TODO: reset set flags
}
