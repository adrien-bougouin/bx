#!/bin/bash
#
# CLI option parsing and help output for the bx tool.

################################################################################
# Parse CLI flags and options, capturing remaining positional arguments into a
# caller-specified array variable.
#
# Arguments:
#   positional_arguments_var - Name of the array variable to receive positional
#                              args from.
#
# Side effects:
#   - May update bashfile path via _bx::set_bashfile.
#   - May set option flags via _bx::options::enable_* helpers.
################################################################################
_bx::cli::parse_options() {
  local positional_arguments_var="$1"

  shift

  while [[ $# -gt 0 ]] && [[ $1 =~ ^- ]]; do
    case "$1" in
      --)
        shift
        break
        ;;
      --file=*)
        _bx::set_bashfile "${1#--file=}"
        ;;
      --bashfile=*)
        _bx::set_bashfile "${1#--bashfile=}"
        ;;
      -f | --file | --bashfile)
        _bx::set_bashfile "$2"
        shift
        ;;
      -h | --help) _bx::options::enable_help ;;
      -l | --list) _bx::options::enable_list ;;
      -q | --quiet) _bx::options::enable_quiet ;;
      -v | --version) _bx::options::enable_version ;;
      *) _bx::abort "Unknown option '$1'!" ;;
    esac

    shift
  done

  eval "${positional_arguments_var}=(\"\$@\")"
}

################################################################################
# Print usage information and a summary of all accepted options to stdout.
#
# Globals:
#   __BX_CONSTANT_COMMAND_NAME__ - command name displayed in the usage line.
#
# Outputs:
#   Writes formatted help text to stdout.
################################################################################
_bx::cli::print_help() {
  _bx::display::info "$(
    cat <<-HELP
			Usage: ${__BX_CONSTANT_COMMAND_NAME__} [options] [--] [recipe] ...

			Options:
			{{indent}}-f FILE, --file=FILE, --bashfile=FILE
			{{indent}}{{indent}}Read FILE as a bashfile. Only one bashfile may be specified.
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
