#!/bin/bash

bake::_cli::_parse_options() {
  local recipes_ref="$1"

  shift

  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      --)
        shift
        break
        ;;
      -f | --file | --bakefile)
        bake::_set_bakefile "$2"
        shift
        ;;
      -h | --help) bake::options::enable_help ;;
      -l | --list) bake::options::enable_list ;;
      -s | --silent | -q | --quiet) bake::options::enable_quiet ;;
      -v | --version) bake::options::enable_version ;;
      *) bake::abort "Unknown option '$1'!" ;;
    esac

    shift
  done

  eval "${recipes_ref}=(\"\$@\")"
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
