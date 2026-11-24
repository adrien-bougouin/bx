#!/usr/bin/env bash

__BX_RECIPE_IGNORE_PATTERNS__=("^_" "^_?bx::" "^_?bx$")
__BX_RECIPES__=()

_bx::recipe_registry::register_ignore_patterns() {
  __BX_RECIPE_IGNORE_PATTERNS__+=("$@")
}

_bx::recipe_registry::full_ignore_pattern() {
  local patterns_join

  printf -v patterns_join "%s|" "${__BX_RECIPE_IGNORE_PATTERNS__[@]}"

  printf "(%s)" "${patterns_join%|}"
}

_bx::recipe_registry::load() {
  local ignore_pattern

  ignore_pattern="$(_bx::recipe_registry::full_ignore_pattern)"

  while IFS='' read -r recipe_definition; do
    local recipe="${recipe_definition#"declare -f "}"

    [[ ${recipe} =~ ${ignore_pattern} ]] && continue
    _bx::annotations::include "${recipe}" && continue

    _bx::recipe::load_annotations "${recipe}"

    __BX_RECIPES__+=("${recipe}")
  done < <(declare -F)

  readonly __BX_RECIPES__
}

_bx::recipe_registry::size() {
  printf "%d" "${#__BX_RECIPES__[@]}"
}

_bx::recipe_registry::print_completion_list() {
  [[ $(_bx::recipe_registry::size) -eq 0 ]] && return

  local completion_prefix="${1:-}"

  local recipe
  for recipe in "${__BX_RECIPES__[@]}"; do
    [[ ${recipe} == "${completion_prefix}"* ]] || continue

    _bx::display::info "${recipe}"
  done
}

_bx::recipe_registry::print_list() {
  [[ $(_bx::recipe_registry::size) -eq 0 ]] && return

  local recipe
  for recipe in "${__BX_RECIPES__[@]}"; do
    local annotations=""
    local help_lines=()
    local help_line

    if [[ ${recipe} == "$(_bx::recipe_registry::default)" ]]; then
      annotations="${annotations} [@default]"
    fi

    if _bx::recipe::must_confirm "${recipe}"; then
      annotations="${annotations} [@confirm]"
    fi

    while IFS= read -r help_line || [[ -n ${help_line} ]]; do
      help_lines+=("${help_line}")
    done < <(_bx::recipe::help "${recipe}")

    _bx::display::format "${recipe}{{bold}}${annotations}{{normal}}"
    if [[ ${#help_lines[@]} -gt 0 ]]; then
      local first_line="${__BOOL_TRUE__}"
      local padding_reference="${recipe}${annotations} "
      # Assuming a 100-column terminal and at most 70 characters per help line,
      # the recipe name and comment marker get at most 30 columns; accounting
      # for the 2-character "# " prefix, the padding is 28 spaces.
      local padding="                            "

      for help_line in "${help_lines[@]}"; do
        if [[ ${first_line} == "${__BOOL_TRUE__}" ]] \
          && [[ ${#padding_reference} -le ${#padding} ]]; then
          local repadding="${padding:${#padding_reference}} "

          _bx::display::format "${repadding}{{dim}}# ${help_line}{{normal}}"
        else
          printf "\n"
          _bx::display::format "${padding}{{dim}}# ${help_line}{{normal}}"
        fi

        first_line="${__BOOL_FALSE__}"
      done
    fi

    printf "\n"
  done

  printf "\n"
  _bx::display::info "Sourced from $(_bx::bashfile::loaded_path)"
}

_bx::recipe_registry::include() {
  [[ ${#__BX_RECIPES__[@]} -eq 0 ]] && return "${__BOOL_FALSE__}"

  local candidate="$1"

  local recipe
  for recipe in "${__BX_RECIPES__[@]}"; do
    [[ ${candidate} == "${recipe}" ]] && return "${__BOOL_TRUE__}"
  done

  return "${__BOOL_FALSE__}"
}
