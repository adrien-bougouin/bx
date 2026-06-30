#!/bin/bash

bake::recipe::execute() {
  local recipe="$1"
  local args=("${@:2}")

  bake::_state::_set_executing "${recipe}"
  bake::recipe::_execute_requirements "${recipe}"

  if ! bake::options::quiet; then
    printf "%s%s%s%s\n" \
      "$(bake::term::style::bold)" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "$(bake::term::style::clear)"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}
