# `bx` Vision
`bx` is a `make`-like task runner in which **Bash is the configuration language**.

This document states what `bx` is, why it exists, and the principles it is built on.

## What `bx` is
`bx` reads a `Bashfile`, treats the Bash functions it declares as *recipes*, and invokes them by name.

The `Bashfile` is plain Bash, not a configuration format.
It can be read and linted like any other script, and its recipes are ordinary Bash functions.

## Why `bx` exists
Bash is usually already at hand and well suited to describing *what* to do, but it is less comfortable as an *entry point*.

Existing task runners tend to fill that gap with a second language.
A `Makefile`, for instance, has its own syntax, tab-sensitive rules and escaping rules; embedding a shell command in a recipe often becomes an escaping exercise.
Escaping is not the only cost: a second syntax and a second set of rules must also be maintained for what is ultimately shell work.

**`bx` is a thin layer around Bash.**
It provides the affordances people tend to expect from a task runner--discovery, listing, chaining, arguments, tracing, confirmation, nested invocation--while leaving the work itself to the Bash the user already writes.

## Principles
The vision rests on three principles.

### 1. Favor Bash features over `bx` features
Using `bx` should not require learning another language: the `Bashfile` is Bash, the recipes are Bash functions, and the arguments are Bash arguments.
Someone who knows Bash already knows most of `bx`.

`bx` does not re-invent what Bash already does.
For instance, it prints a recipe-level trace and leaves command-level tracing to xtrace (`set -x`), rather than implementing its own tracing system.
Both use the same `PS4`-derived prefix, so they interleave cleanly.

### 2. Keep code short and simple
`bx` must support old Bash 3.2 (the version shipped with macOS), so keeping its code thin is more a maintenance strategy than an aesthetic preference: a smaller `bx` is easier to trust and to keep working.

### 3. Only implement what improves the UX
`bx` adds behaviour only where the `Bashfile` cannot remove friction on its own--the friction of **invoking** recipes, rather than of **authoring** them.

| Friction                                           | What `bx` provides                       |
|:-------------------------------------------------- |:---------------------------------------- |
| "What can I invoke here?"                          | `bx --list`, with descriptions           |
| "What does this recipe do?"                        | `@help` annotations, shown by `--list`   |
| "What is this recipe actually doing?"              | Recipe-level trace, aligned with `PS4`   |
| "I need to invoke this recipe from a subdirectory" | Upward `Bashfile` lookup                 |
| "I need to invoke three recipes"                   | Recipe chaining: `bx format lint test`   |
| "I need to pass a flag through"                    | Recipe arguments: `bx 'lint --strict'`   |
| "That recipe is destructive"                       | `@confirm`, with a `[y/N]` prompt        |
| "Nobody is here to answer the prompt"              | `-y` / `--yes`, for non-interactive mode |
| "One recipe needs to invoke another recipe"        | `bx::invoke`, inside the recipe runtime  |

## Evolving this document
This document is deliberately short: it changes when the vision changes, not when the feature set changes.
Feature-level documentation belongs in the [README](README.md) and the [manual page](man/man1/bx.1).
