#!/bin/bash

__BAKE_CLI_OPTIONS_OFFSET__=0

bake::cli::parse_options() {
  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      -f | --file | --bakefile)
        bake::set_bakefile "$(realpath "$2")"
        shift

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 2))
        ;;

      -h | --help)
        bake::options::enable_help

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 1))
        ;;

      -s | --silent | -q | --quiet)
        bake::options::enable_quiet

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 1))
        ;;

      *)
        bake::abort "unknown option '$1'"
        ;;
    esac

    shift
  done

  readonly __BAKE_CLI_OPTIONS_OFFSET__
}

bake::cli::options_offset() {
  printf "%d" "${__BAKE_CLI_OPTIONS_OFFSET__}"
}

bake::cli::print_help() {
  printf "Usage: %s [options] [recipe] ...\n\n" "${__BAKE_CONSTANT_COMMAND_NAME__}"

  printf "Options:\n"
  printf "%s-f FILE, --file FILE, --bakefile FILE\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s   Read FILE as a bakefile.\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s-h, --help\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s   Show this help.\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
}
