#!/bin/bash

bake::recipe::execute() {
  local recipe=$1
  local args=("${@:2}")

  bake::state::set_executing "${recipe}"
  bake::recipe::execute_requirements "${recipe}"

  if ! bake::options::quiet; then
    printf "%s%s%s%s\n" \
      "$(bake::term::style::bold)" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "$(bake::term::style::clear)"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}
