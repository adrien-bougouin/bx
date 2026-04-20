#!/bin/bash

bake::cli::help() {
  echo "TODO: help"
}

bake::cli::argparse() {
  export __BAKE_ARGPARSE_SHIFT_COUNT__=0

  export __BAKE_OPTION_LIST__=false
  export __BAKE_OPTION_BAKEFILE__=""

  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      -f | --file | --bakefile)
        __BAKE_OPTION_BAKEFILE__=$(realpath "$2")
        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 2))
        shift
        ;;

      -l | --list)
        __BAKE_OPTION_LIST__=true
        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 1))
        ;;

      -h | --help)
        bake::cli::help
        exit
        ;;

      *)
        echo "Unknown option '$1'"
        exit 1
        ;;
    esac

    shift
  done

  readonly __BAKE_ARGPARSE_SHIFT_COUNT__

  readonly __BAKE_OPTION_LIST__
  readonly __BAKE_OPTION_BAKEFILE__
}
