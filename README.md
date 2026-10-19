# `bx`

[![CI/CD](https://img.shields.io/github/actions/workflow/status/adrien-bougouin/bx/cicd.yml?branch=main&logo=github&label=CI/CD)](https://github.com/adrien-bougouin/bx/actions/workflows/cicd.yml)
[![License](https://img.shields.io/github/license/adrien-bougouin/bx?label=License)](https://github.com/adrien-bougouin/bx/blob/main/LICENSE)
[![Latest](https://img.shields.io/github/v/release/adrien-bougouin/bx?logo=github&label=Latest)](https://github.com/adrien-bougouin/bx/releases/latest)
[![Installs](https://img.shields.io/github/downloads/adrien-bougouin/bx/install.sh?displayAssetName=false&label=Installs)](https://github.com/adrien-bougouin/bx#installation)

A pure Bash-configurable build automation and recipe invocation tool.

`bx` reads a Bash configuration file, `Bashfile`, treats the functions as recipes, and invokes them by name.
A recipe declared in the `Bashfile` as follows:
```bash
lint() {
  shellcheck "src/*.sh"
}
```
is invoked with
```bash
bx lint
```

## Requirements
All you need is Bash 3.2 or above.

## Installation
```bash
curl -fsSL "https://github.com/adrien-bougouin/bx/releases/latest/download/install.sh" | bash
```

<details>
  <summary>Updating</summary>

  ```bash
  bx-update
  ```
</details>

<details>
  <summary>Uninstalling</summary>

  ```bash
  bx-uninstall
  ```
</details>


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
    -y, --yes
        Do not ask for confirmation before invoking a recipe
        (automatically confirm).
```

## Key Features
### `Bashfile` lookup
`bx` looks for the nearest `Bashfile`, walking up the directory tree from the current working directory, allowing invocation of recipes from any subdirectory of a project.

### Recipe chaining
Invoke multiple recipes in one go.

```bash
bx format lint
```

### Recipe arguments
Pass arguments to recipes by quoting the recipe name and its arguments.

```bash
bx format 'lint --some-lint-option'
```

### Recipe annotations
Annotations are directives placed inside a recipe body to instruct `bx` on how to treat the recipe.

All annotations must appear at the top of the recipe body, before any executable instruction.

#### `@help`
Describe a recipe with the annotation `@help`.
The description is displayed by `bx --list`, and can span multiple lines by passing several arguments.

```bash
# Bashfile

my_recipe() {
  @help "Line 1" \
    "Line 2"

  # ...
}
```

#### `@default`
Set which recipe to invoke when executing `bx` without an explicit recipe.

```bash
# Bashfile

my_recipe() {
  @default

  # ...
}
```

#### `@confirm`
Mark a recipe as requiring user confirmation before it is executed.
When a recipe carries the `@confirm` annotation, `bx` displays a `[y/N]` prompt and only proceeds if the user answers `y`.

```bash
# Bashfile

dangerous-recipe() {
  @confirm

  rm -rf ./build
}
```

Pass option `-y` (or `--yes`) to skip all confirmation prompts and run every recipe automatically.

### Nested recipe invocation (`bx::invoke`)
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

Similar to when invoking recipes with `bx`, pass option `-y` (or `--yes`) to `bx::invoke` to auto-confirm.

### Scope boundaries
Recipes declared as regular functions (syntax `recipe_name() { ... }`) share the same scope.
If they modify global variables, the changes will be visible from other recipes.

Recipes declared as a subprocess (syntax `recipe_name() ( ... )`) operate in a fork.
Nested invocations inside a subprocess recipe see its global changes; later top-level invocations do not.

```bash
# Bashfile

GLOBAL="default-value"

print-global() {
  echo "GLOBAL=${GLOBAL}"
}

change-global() {
  GLOBAL="changed-value"

  bx::invoke print-global
}

change-global--subprocess() (
  GLOBAL="changed-value"

  bx::invoke print-global
)
```

```bash
bx -q change-global print-global
# stdout: GLOBAL=changed-value
# stdout: GLOBAL=changed-value

bx -q change-global--subprocess print-global
# stdout: GLOBAL=changed-value
# stdout: GLOBAL=default-value
```

### Shell options
Recipes can set their own shell options.
For instance, a recipe can set `set -x` to trace the recipe instructions.

```bash
# Bashfile

recipe() {
  # Instructions here will never be traced.

  set -x

  # Instructions here will be traced.
}
```

Shell options set from a recipe are isolated to that recipe.
Subsequent recipe invocations, or nested recipe invocations, will not be impacted by shell option changes from another recipe.
