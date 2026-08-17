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
#   - May update bakefile path via bake::set_bakefile.
#   - May set option flags via bake::options::enable_* helpers.
################################################################################
bake::cli::parse_options() {
  local positional_arguments_ref="$1"

  shift

  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      --)
        shift
        break
        ;;
      --file=*)
        bake::set_bakefile "${1#--file=}"
        ;;
      --bakefile=*)
        bake::set_bakefile "${1#--bakefile=}"
        ;;
      -f | --file | --bakefile)
        bake::set_bakefile "$2"
        shift
        ;;
      -h | --help) bake::options::enable_help ;;
      -l | --list) bake::options::enable_list ;;
      -q | --quiet) bake::options::enable_quiet ;;
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
#
# Outputs:
#   Writes formatted help text to stdout.
################################################################################
bake::cli::print_help() {
  bake::display::info "$(
    cat <<-HELP
			Usage: ${__BAKE_CONSTANT_COMMAND_NAME__} [options] [--] [recipe] ...

			Options:
			{{indent}}-f FILE, --file=FILE, --bakefile=FILE
			{{indent}}{{indent}}Read FILE as a bakefile. Only one bakefile may be specified.
			{{indent}}-h, --help
			{{indent}}{{indent}}Show this help.
			{{indent}}-l, --list
			{{indent}}{{indent}}Show the available recipes.
			{{indent}}-q, --quiet
			{{indent}}{{indent}}Do not display the invoked recipe traces, nor the xtrace output.
			{{indent}}-v, --version
			{{indent}}{{indent}}Show version.
		HELP
  )"
}
