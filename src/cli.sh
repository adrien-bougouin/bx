#!/bin/bash
#
# CLI option parsing and help output for the bake tool.

################################################################################
# Parse CLI flags and options, capturing remaining positional arguments into a
# caller-specified array variable.
#
# Args:
#   positional_arguments_ref - Name of the array variable to receive positional
#                              args from.
#
# Side effects:
#   - May update bakefile path via bake::_set_bakefile.
#   - May set option flags via bake::options::enable_* helpers.
################################################################################
bake::_cli::_parse_options() {
  local positional_arguments_ref="$1"

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

  eval "${positional_arguments_ref}=(\"\$@\")"
}

################################################################################
# Print usage information and a summary of all accepted options to stdout.
#
# Globals:
#   __BAKE_CONSTANT_COMMAND_NAME__ - command name displayed in the usage line.
#   __BAKE_CONSTANT_TEXT_INDENT__  - indent prefix for each option line.
#
# Outputs:
#   Writes formatted help text to stdout.
################################################################################
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
