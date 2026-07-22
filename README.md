# Bake

[![CI Checks](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml/badge.svg)](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml)

Bake is a Bash configurable build automation and task invocation tool.

Write **recipes** in Bash 3.2+; invoke them like you would with Make.

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

## Features

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

### Recipe pre-conditions (`@require: ...`)
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

### Nested invocation (`bake::recipes::invoke`)
Invoke other recipes from within a recipe at runtime.

```bash
# Bakefile

complex-recipe() {
  echo "Pre-processing..."
  bake::recipes::invoke simple-recipe
  echo "Post-processing..."
}

simple-recipe() {
  echo "Simple recipe executed!"
}
```

### Scope boundaries
Recipes defined with `()` (subprocess) have their own scope and cannot modify global variables. Recipes defined with `{}` (function) share the parent scope.

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
