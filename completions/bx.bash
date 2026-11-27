#!/usr/bin/env bash
#
# Bash completion for bx recipes.

_bx::completion() {
  COMPREPLY=()

  [[ ${COMP_CWORD} -lt 1 ]] && return 0

  local prefix="${COMP_WORDS[COMP_CWORD]}"

  # Ignore bx options.
  [[ ${prefix} == -* ]] && return 0

  # bx parses the already-typed options (including -f) and filters recipes by
  # the last positional word, i.e. the word currently being completed.
  local recipe
  while IFS= read -r recipe; do
    COMPREPLY+=("${recipe}")
  done < <(bx --completion-list "${COMP_WORDS[@]:1:COMP_CWORD}" 2>/dev/null)
}

complete -o default -F _bx::completion bx
