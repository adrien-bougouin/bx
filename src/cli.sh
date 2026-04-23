#!/bin/bash

bake::cli::help() {
  printf "Usage: %s [options] [recipe] ...\n\n" "${__BAKE_COMMAND__}"

  printf "Options:\n"
  printf "%s-f FILE, --file FILE, --bakefile FILE\n" "${__BAKE_INDENT__}"
  printf "%s   Read FILE as a bakefile.\n" "${__BAKE_INDENT__}"
  printf "%s-h, --help\n" "${__BAKE_INDENT__}"
  printf "%s   Show this help.\n" "${__BAKE_INDENT__}"
}

bake::cli::argparse() {
  export __BAKE_ARGPARSE_SHIFT_COUNT__=0

  export __BAKE_OPTION_HELP__=false
  export __BAKE_OPTION_BAKEFILE__=""

  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      -f | --file | --bakefile)
        __BAKE_OPTION_BAKEFILE__=$(realpath "$2")
        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 2))
        shift
        ;;

      -h | --help)
        __BAKE_OPTION_HELP__=true
        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 1))
        ;;

      *)
        printf "Unknown option '%s'\n" "$1"
        exit 1
        ;;
    esac

    shift
  done

  readonly __BAKE_ARGPARSE_SHIFT_COUNT__

  readonly __BAKE_OPTION_HELP__
  readonly __BAKE_OPTION_BAKEFILE__
}
