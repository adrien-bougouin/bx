---
name: bx
description: >
  Reference for `bx`, the recipe invocation tool. Use when working in a project
  with a `Bashfile` or when the user mentions `bx`.
---

# `bx`

## Discovery
- `bx --help` Show `bx` command line help
- `bx --list` Show the available recipes

## Execution
- `bx` Invoke the default recipe
- `bx <RECIPE>` Invoke a specific recipe
- `bx <RECIPE1> <RECIPE2>` Invoke multiple recipes
- `bx '<RECIPE> <ARG1> <ARG2>'` Invoke a recipe with arguments
- `bx -y <RECIPE>` Do not ask for confirmation before invoking a recipe
- `bx -q <RECIPE>` Do not display the recipe traces, nor the xtrace output
- `bx -f <FILE> <RECIPE>` Read `<FILE>` as the Bashfile

```bash
bx format lint      # invoke the recipes 'format' and 'lint'
bx 'format --check' # invoke 'format' with the argument '--check'
```

## Bashfile Syntax (Examples)
```bash
# A Bashfile is a Bash script sourced by 'bx'; its functions are recipes.
# Functions prefixed with '_' are private, and 'bx' and 'bx::*' are reserved.
# Other names may contain '-' and '::' (e.g. 'features::check').
#
# Annotations must appear at the top of a recipe body, before any executable
# instruction. They may be declared in any order:
#   @help "..."   Describe the recipe in 'bx --list'; accepts several
#                 arguments to span multiple lines.
#   @default      Invoke this recipe when 'bx' runs without a recipe.
#   @confirm      Ask for confirmation before invoking (skipped with '-y').

default_recipe() {
  @help "Run the default workflow." \
    "The description can span multiple lines."
  @default

  # Invoke other recipes without spawning a new 'bx' process. Each argument
  # is a complete invocation, like on the command line. Pass '-y' as the
  # first argument to auto-confirm nested recipe invocations.
  bx::invoke lint 'tests --verbose'
}

lint() {
  @help "Lint the sources."

  shellcheck src/*.sh
}

tests() {
  @help "Run the test suite."

  # Recipes receive arguments as regular Bash positional parameters.
  ./tests.sh "$@"
}

clean() {
  @confirm

  rm -rf ./build
}
```

## Notes
Commonly used commands and scripts should be turned into `bx` recipes.
