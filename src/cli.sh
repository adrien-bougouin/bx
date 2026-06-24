#!/bin/bash

export __BAKE_ARGPARSE_SHIFT_COUNT__=0

bake::cli::init() {
  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      -f | --file | --bakefile)
        bake::set_bakefile "$(realpath "$2")"
        shift

        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 2))
        ;;

      -h | --help)
        bake::options::enable_help

        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 1))
        ;;

      -s | --silent | -q | --quiet)
        bake::options::enable_quiet

        __BAKE_ARGPARSE_SHIFT_COUNT__=$((__BAKE_ARGPARSE_SHIFT_COUNT__ + 1))
        ;;

      *)
        bake::abort "unknown option '$1'"
        ;;
    esac

    shift
  done

  readonly __BAKE_ARGPARSE_SHIFT_COUNT__
}

bake::cli::print_help() {
  local program_name=$1
  local indent="$2"

  printf "Usage: %s [options] [recipe] ...\n\n" "${program_name}"

  printf "Options:\n"
  printf "%s-f FILE, --file FILE, --bakefile FILE\n" "${indent}"
  printf "%s   Read FILE as a bakefile.\n" "${indent}"
  printf "%s-h, --help\n" "${indent}"
  printf "%s   Show this help.\n" "${indent}"
}
