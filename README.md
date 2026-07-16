# `bake`

[![CI Checks](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml/badge.svg)](https://github.com/adrien-bougouin/bake/actions/workflows/ci_checks.yml)

`bake` is a `bash` configurable build automation and task running tool.

Write **recipes** in `bash`; run them like you would with `make`.

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
Clone this repository, then run:

```shell
./bin/bake install
```

## Features

### Recipe chaining
Call recipes in one go.

```shell
bake format lint tests
```

### Recipe arguments
Pass arguments to recipes just like any other command.

```shell
bake format "lint --exclude SC2313" tests
```

### Default recipe (`@default`)
Set which recipe to execute when calling `bake` without explicit recipe.

Use the `@default` annotation (recommended), or call `bake::recipes::set_default` (when calling the default with arguments).

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
List recipes that must be executed before the current recipe.

Use the `@require:` annotation to set one or more recipes to execute before the current recipe. Recipe arguments are also supported.

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
