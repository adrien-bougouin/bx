#!/bin/bash

_bake::utils::string::trim() {
  local input="$1"
  local pattern="$2"

  local previous_trim=""
  local last_trim="${input}"

  until [[ ${previous_trim} == "${last_trim}" ]]; do
    previous_trim="${last_trim}"

    last_trim="${last_trim#"${pattern}"}"
    last_trim="${last_trim%"${pattern}"}"
  done

  printf "%s" "${last_trim}"
}
