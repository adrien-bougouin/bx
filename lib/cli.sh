#!/usr/bin/env bash

__BAKE_OPTION_LIST__=false

bake:cli:help () {
  echo "TODO: help"
}

bake:cli:argparse () {
  local shift_count=0

  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      -f|--file|--bakefile)
        __BAKEFILE__=$(realpath "$2")
        shift_count=$((shift_count+2))
        shift
        ;;

      -l|--list)
        __BAKE_OPTION_LIST__=true
        shift_count=$((shift_count+1))
        ;;

      -h|--help)
        bake:cli:help
        exit
        ;;

      *)
        echo "Unknown option '$1'"
        exit 1
        ;;
    esac

    shift
  done

  echo ${shift_count}
}
