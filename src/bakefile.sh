#!/bin/bash

__BAKE_BAKEFILE__=

bake::bakefile() {
  printf "%s" "${__BAKE_BAKEFILE__:-"${__BAKE_WORKING_DIRECTORY__}/Bakefile"}"
}

bake::_set_bakefile() {
  __BAKE_BAKEFILE__="$1"
}
