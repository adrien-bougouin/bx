#!/bin/bash

export __BAKE_ARGPARSE_SHIFT_COUNT_

export __BAKE_OPTION_BAKEFILE__
export __BAKE_OPTION_HELP__
export __BAKE_OPTION_QUIET__

bake::cli::init() {
  __BAKE_ARGPARSE_SHIFT_COUNT__=0

  __BAKE_OPTION_BAKEFILE__=""
  __BAKE_OPTION_HELP__=false
  __BAKE_OPTION_QUIET__=false

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

      -s | --silent | -q | --quiet)
        __BAKE_OPTION_QUIET__=true
        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 1))
        ;;

      *)
        bake::abort "unknown option '$1'"
        ;;
    esac

    shift
  done

  readonly __BAKE_ARGPARSE_SHIFT_COUNT__

  readonly __BAKE_OPTION_BAKEFILE__
  readonly __BAKE_OPTION_HELP__
  readonly __BAKE_OPTION_QUIET__
}

bake::cli::help() {
  local program_name=$1
  local indent="$2"

  printf "Usage: %s [options] [recipe] ...\n\n" "${program_name}"

  printf "Options:\n"
  printf "%s-f FILE, --file FILE, --bakefile FILE\n" "${indent}"
  printf "%s   Read FILE as a bakefile.\n" "${indent}"
  printf "%s-h, --help\n" "${indent}"
  printf "%s   Show this help.\n" "${indent}"
}
