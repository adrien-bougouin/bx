#!/bin/bash

bake::recipe::execute() {
  local recipe=$1
  local args=("${@:2}")

  bake::progress::set_executing "${recipe}"
  bake::recipe::execute_requirements "${recipe}"

  if ! bake::options::quiet; then
    printf "%s%s%s%s\n" \
      "${__BAKE_TERM_BOLD__}" \
      "${recipe}" \
      "${args+" ${args[*]}"}" \
      "${__BAKE_TERM_RESET__}"
  fi

  eval "${recipe}" "${args+"${args[@]}"}"
}
