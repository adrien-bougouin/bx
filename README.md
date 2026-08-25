# `bx` (Bash executor)

[![CI](https://github.com/adrien-bougouin/bx/actions/workflows/ci.yml/badge.svg)](https://github.com/adrien-bougouin/bx/actions/workflows/ci.yml)

`bx` is a Bash configurable build automation and recipe invocation tool.

`bx` reads a `Bashfile`, treats Bash functions as recipes, and invokes them via `bx <recipe>`.

```bash
# file: Bashfile

BIN_PATH="$(realpath ./bin)"

SOURCES=(./bin/bx $(find ./src -name "*.sh"))

lint() {
  local args=("--exclude" "SC1090,SC1091,SC2329" "$@")

  set -x

  shellcheck "${args[@]}" "${SOURCES[@]}"
}

format() {
  set -x

  shfmt -i 2 -ci -bn -s -w "${SOURCES[@]}"
}
```

## Installation
Clone this repository, then execute:

```shell
./bin/bx install
```

## Quick Reference
```
$ bx --help
Usage: bx [options] [--] [recipe] ...

Options:
    -f FILE, --file=FILE, --bashfile=FILE
        Read FILE as a bashfile. Only one bashfile may be specified.
    -h, --help
        Show this help.
    -l, --list
        Show the available recipes.
    -q, --quiet
        Do not display the invoked recipe traces, nor the xtrace output.
    -v, --version
        Show version.
```

## Features

### `Bashfile` lookup
`bx` looks for the nearest `Bashfile`, walking up the directory tree from the current working directory, allowing invocation of recipes from any subdirectory of a project.

### Recipe chaining
Invoke multiple recipes in one go.

```shell
bx format lint
```

### Recipe arguments
Pass arguments to recipes by quoting the recipe name and its arguments.

```shell
bx format 'lint --some-lint-option'
```

### Recipe documentation (`@help`)
Describe a recipe with the annotation `@help`. The description is displayed by
`bx --list` and `bx --help`, and can span multiple lines by passing several
arguments.

```bash
# Bashfile

my_recipe() {
  @help "Line 1" \
    "Line 2"

  # ...
}
```

### Default recipe (`@default`)
Set which recipe to invoke when executing `bx` without an explicit recipe.

```bash
# Bashfile

my_recipe() {
  @default

  # ...
}
```

### Nested invocation (`bx::invoke`)
Invoke other recipes from within a recipe at runtime.

```bash
# Bashfile

complex-recipe() {
  echo "Pre-processing..."
  bx::invoke simple-recipe
  echo "Post-processing..."
}

simple-recipe() {
  echo "Simple recipe executed!"
}
```

### Scope boundaries
Recipes defined with `()` (subprocess) have their own scope: if they modify global variables, the changes won't be visible from other recipes.
Recipes defined with `{}` (function) share the parent scope: if they modify global variables, the changes will be visible from other recipes.

```bash
# Bashfile

GLOBAL="default-value"

change-global() {
  GLOBAL="changed-value"
}

change-global--subprocess() (
  GLOBAL="changed-value"
)

print-global() {
  echo "GLOBAL=${GLOBAL}"
}
```

```shell
bx -q change-global print-global              # GLOBAL=changed-value
bx -q change-global--subprocess print-global  # GLOBAL=default-value
```

### Shell options isolation
`bx` isolates shell options locally (e.g. `set -x` to trace execution), preventing changes from leaking into other recipes or into `bx` itself.

```bash
# Bashfile

recipe-1() {
  # Instructions here will never be traced.

  set -x

  # Instructions here will be traced.
}
```
