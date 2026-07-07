#!/bin/bash

__BAKE_CLI_OPTIONS_OFFSET__=0

bake::_cli::_parse_options() {
  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      -f | --file | --bakefile)
        bake::_set_bakefile "$2"
        shift

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 2))
        ;;

      -h | --help)
        bake::options::enable_help

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 1))
        ;;

      -l | --list)
        bake::options::enable_list

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 1))
        ;;

      -s | --silent | -q | --quiet)
        bake::options::enable_quiet

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 1))
        ;;

      -v | --version)
        bake::options::enable_version

        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 1))
        ;;

      --)
        __BAKE_CLI_OPTIONS_OFFSET__=$((__BAKE_CLI_OPTIONS_OFFSET__ + 1))
        break
        ;;

      *)
        bake::abort "Unknown option '$1'!"
        ;;
    esac

    shift
  done

  readonly __BAKE_CLI_OPTIONS_OFFSET__
}

bake::_cli::_options_offset() {
  printf "%d" "${__BAKE_CLI_OPTIONS_OFFSET__}"
}

bake::_cli::print_help() {
  printf "Usage: %s [options] [--] [recipe] ...\n\n" "${__BAKE_CONSTANT_COMMAND_NAME__}"

  printf "Options:\n"
  printf "%s-f FILE, --file FILE, --bakefile FILE\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s   Read FILE as a bakefile.\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s-h, --help\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s   Show this help.\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s-l, --list\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s   Show the available recipes.\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s-s, --silent, -q, --quiet\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s   Do not display the executed recipe name and arguments.\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s-v, --version\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
  printf "%s   Show version.\n" "${__BAKE_CONSTANT_TEXT_INDENT__}"
}
