#!/bin/bash

bake::string::capitalize() {
  printf "%s%s" "$(printf "%s" "${1:0:1}" | tr '[:lower:]' '[:upper:]')" "${1:1}"
}
