#!/usr/bin/env bash
#
# CLI option parsing and help output for the bx tool.

__BX_CLI_HELP_REQUESTED__="${__BOOL_FALSE__}"
__BX_CLI_LIST_REQUESTED__="${__BOOL_FALSE__}"
__BX_CLI_VERSION_REQUESTED__="${__BOOL_FALSE__}"

################################################################################
# Check whether help was requested on the command line.
#
# Returns:
#   0 (true) if -h or --help was given, 1 (false) otherwise.
################################################################################
_bx::cli::help_requested() {
  return "${__BX_CLI_HELP_REQUESTED__}"
}

################################################################################
# Mark help as requested.
#
# Side effects:
#   Sets __BX_CLI_HELP_REQUESTED__ to true.
################################################################################
_bx::cli::request_help() {
  __BX_CLI_HELP_REQUESTED__="${__BOOL_TRUE__}"
}

################################################################################
# Check whether listing recipes was requested on the command line.
#
# Returns:
#   0 (true) if -l or --list was given, 1 (false) otherwise.
################################################################################
_bx::cli::list_requested() {
  return "${__BX_CLI_LIST_REQUESTED__}"
}

################################################################################
# Mark listing recipes as requested.
#
# Side effects:
#   Sets __BX_CLI_LIST_REQUESTED__ to true.
################################################################################
_bx::cli::request_list() {
  __BX_CLI_LIST_REQUESTED__="${__BOOL_TRUE__}"
}

################################################################################
# Check whether the version was requested on the command line.
#
# Returns:
#   0 (true) if -v or --version was given, 1 (false) otherwise.
################################################################################
_bx::cli::version_requested() {
  return "${__BX_CLI_VERSION_REQUESTED__}"
}

################################################################################
# Mark the version as requested.
#
# Side effects:
#   Sets __BX_CLI_VERSION_REQUESTED__ to true.
################################################################################
_bx::cli::request_version() {
  __BX_CLI_VERSION_REQUESTED__="${__BOOL_TRUE__}"
}

################################################################################
# Parse CLI flags and options, capturing remaining positional arguments into a
# caller-specified array variable.
#
# Arguments:
#   positional_arguments_var - Name of the array variable to receive positional
#                              args from.
#
# Side effects:
#   - May update bashfile path via _bx::bashfile::set_path.
#   - May set CLI requests via _bx::cli::request_* helpers.
#   - May set option flags via _bx::options::{enable,disable}_* helpers.
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
      --bashfile=*)
        _bx::bashfile::set_path "${1#--bashfile=}"
        ;;
      --file=*)
        _bx::bashfile::set_path "${1#--file=}"
        ;;
      -f | --file | --bashfile)
        _bx::bashfile::set_path "$2"
        shift
        ;;
      -h | --help) _bx::cli::request_help ;;
      -l | --list) _bx::cli::request_list ;;
      -q | --quiet)
        _bx::options::disable_recipe_trace
        _bx::options::disable_xtrace
        ;;
      -v | --version) _bx::cli::request_version ;;
      -y | --yes) _bx::options::enable_auto_confirm ;;
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
			{{indent}}-y, --yes
			{{indent}}{{indent}}Do not ask for confirmation before invoking a recipe
			{{indent}}{{indent}}(automatically confirm).
		HELP
  )"
}
