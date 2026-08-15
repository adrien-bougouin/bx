# Bake

[![CI Checks](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml/badge.svg)](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml)

Bake is a Bash configurable build automation and task invocation tool.

Bake reads a Bakefile, treats Bash functions as recipes, and invokes them via `bake <recipe>`.

```bash
# file: Bakefile

BIN_PATH="$(realpath ./bin)"

SOURCES=(./bin/bake $(find ./src -name "*.sh"))

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
./bin/bake install
```

## Quick Reference
```
$ bake --help
Usage: bake [options] [--] [recipe] ...

Options:
    -f FILE, --file FILE, --bakefile FILE
        Read FILE as a bakefile. Only one bakefile may be specified.
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

### Bakefile lookup
Bake automatically look for the nearest Bakefile, walking up the directory tree from the current working directory.
This allows to invoke recipes from any subdirectory of a project.

### Recipe chaining
Invoke multiple recipes in one go.

```shell
bake format lint
```

### Recipe arguments
Pass arguments to recipes by quoting the recipe name and its arguments.

```shell
bake "format" "lint --some-lint-option"
```

### Recipe documentation (`@help`)
Describe a recipe with the annotation `@help`. The description is displayed by
`bake --list` and `bake --help`, and can span multiple lines by passing several
arguments.

```bash
# Bakefile

my_recipe() {
  @help "Line 1" \
    "Line 2"

  # ...
}
```

### Default recipe (`@default`)
Set which recipe to invoke when executing Bake without an explicit recipe.

Use the annotation `@default` (recommended), or use the function `bake::recipes::set_default` (for invoking the default recipe with arguments).

```bash
# Bakefile

my_recipe() {
  @default

  # ...
}
```

```bash
# Bakefile

bake::recipes::set_default "my_recipe --some-option"

my_recipe() {
  # ...
}
```

### Recipe requirements (`@require:`)
List recipes that must be invoked before the current recipe.

Use the annotation `@require:` to set one or more recipes to invoke before the current recipe. Recipe arguments are also supported.

```bash
# Bakefile

format() {
  # ...
}

lint() {
  local args=("$@")

  # ...
}

my_recipe() {
  @require: format "lint --some-lint-option"

  # ...
}
```

### Nested invocation (`bake`)
Invoke other recipes from within a recipe at runtime.

```bash
# Bakefile

complex-recipe() {
  echo "Pre-processing..."
  bake simple-recipe
  echo "Post-processing..."
}

simple-recipe() {
  echo "Simple recipe executed!"
}
```

### Scope boundaries
Recipes defined with `()` (subprocess) have their own scope and cannot modify global variables.
Recipes defined with `{}` (function) share the parent scope.

```bash
# Bakefile

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
bake -q change-global print-global              # GLOBAL=changed-value
bake -q change-global--subprocess print-global  # GLOBAL=default-value
```

### Shell options isolation
Recipes can change shell options locally (e.g. `set -x` to trace execution).
These changes do not leak into other recipes or into Bake itself.

```bash
# Bakefile

recipe-1() {
  # Instructions here will never be traced.

  set -x

  # Instructions here will be traced.
}
```
