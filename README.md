# Bake

[![CI Checks](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml/badge.svg)](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml)

Bake is a Bash configurable build automation and task invocation tool.

Write **recipes** in Bash 3.2+; invoke them like you would with Make.

```bash
# file: Bakefile

BIN_PATH="$(realpath ./bin)"

SOURCES=(./bin/bake $(find ./src -name "*.sh"))
TESTS=($(find ./tests/cases -name "test_*.sh"))

lint() {
  local args=("--exclude" "SC1090,SC1091,SC2329" "$@")

  set -x

  shellcheck "${args[@]}" "${SOURCES[@]}"
  shellcheck "${args[@]}" "${TESTS[@]}"
}

format() {
  set -x

  shfmt -i 2 -ci -bn -s -w "${SOURCES[@]}"
  shfmt -ci -bn -s -w "${TESTS[@]}"
}

tests() {
  PATH="${BIN_PATH}:${PATH}"

  ./tests/main.sh "${1:-"${TESTS[@]}"}"
}
```

## Installation
Clone this repository, then execute:

```shell
./bin/bake install
```

## Features

### Recipe chaining
Invoke recipes in one go.

```shell
bake format lint tests
```

### Recipe arguments
Pass arguments to recipes just like any other command.

```shell
bake format "lint --exclude SC2313" tests
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

bake::recipes::set_default 'my_recipe --some-option'

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

tests() {
  # ...
}

my_recipe() {
  @require: format 'lint --some-lint-option' tests

  # ...
}
```
