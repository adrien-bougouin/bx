#!/bin/bash

set +ex -o pipefail

PASS_COUNT=0
FAIL_COUNT=0

test() {
  local command="$1"
  local expected="$2"
  local actual=$(eval ${command})

  printf "\n%% "
  printf "%s" "${command}"

  if [[ ${expected} != ${actual} ]]; then
    printf " [FAILED]\n"
    printf "  Expected: %q\n" "${expected}"
    printf "  Actual:   %q\n" "${actual}"

    FAIL_COUNT=$((FAIL_COUNT+1))
  else
    printf " [PASSED]\n"

    PASS_COUNT=$((PASS_COUNT+1))
  fi
}

printf "===== %s\n" "$(realpath "$0")"

test "bake --list" "$(cat <<EXPECTED
Recipes:
- recipe_1
recipe_1 () 
{ 
    true
}
- recipe_2
recipe_2 () 
{ 
    true
}
EXPECTED)"

printf "\n===== DONE! %d PASSED; %d FAILED.\n" "${PASS_COUNT}" "${FAIL_COUNT}"

exit "${FAIL_COUNT}"
