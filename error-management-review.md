# `bx` error management review

Date: 2026-11-08
Scope: `bin/`, `src/`, `install.sh`, `dist.bashfile`, `man/man1/bx.1`, and the Cucumber features.
Method: source audit plus behavioural probes run against throwaway Bashfiles in a temporary directory. No project files were modified.

## Summary

Errors originating in user code already point at the user's Bashfile rather than at bx internals: syntax errors raised while sourcing the Bashfile, `command not found`, and `unbound variable` all report the Bashfile path and line. `_bx::abort` consistently uses the `bx:` prefix, and the `BASH_XTRACEFD` warning is a good example of proactive diagnostics.

Three categories of problems remain:

1. **Silent errors** — failures that produce no message at all.
2. **Internal-code leaks** — user mistakes that surface `src/*.sh` paths and line numbers.
3. **Insufficient or misleading diagnostics** — correct failures reported without enough context.

---

## 1. [DONE] Silent errors

### 1.1 [DONE] The `set` override swallows real errors (high severity)

`src/overrides.sh:15-20`:

```bash
set() {
  {
    builtin set "$@"
    _bx::options::xtrace_enabled || builtin set +x
  } 2>/dev/null
}
```

The whole block is silenced. A recipe doing `set -o bogus` therefore exits with status 1 and **no message at all**:

```
$ ./bin/bx -f set.bash r
+ r {
status=1
```

With `-q`, stderr is completely empty.

The redirect exists only to hide the `builtin set +x` line that quiet mode would otherwise trace; it should be narrowed to that statement.

Caveat for the fix: removing the redirect outright makes Bash report `src/overrides.sh: line 17: set: bogus: invalid option name`, i.e. an internal-code location. The override should catch the failure and emit a bx-authored message instead.

Related behavior bug (not error reporting): because `set` is now a shell function, `set -- a b` inside a recipe only changes the wrapper's positional parameters — it silently does nothing to the recipe. Worth documenting or fixing in the same area.

### 1.2 [BY-DESIGN] Failing recipes are silent and leave unbalanced traces (high severity)

`src/recipe.sh:44-58` prints the opening trace, runs `eval`, then prints the closing trace. Under `set -e`, a failing recipe exits before the closing trace:

```
$ ./bin/bx -f fail.bash f      # f() { false; }
+ f {
status=1
```

`return 7` gives `+ g {` and status 7 with no diagnostic. Nested failures leave every enclosing brace unclosed.

This contradicts `man/man1/bx.1:255-260`: "Error messages are printed to standard error with the `bx:` prefix." A recipe that fails with a command that prints nothing (`false`, `grep -q`, a failed `[ ]`) is completely silent.

### 1.3 [DONE] `bx-update` can abort silently before its own error message

`src/subcommands/update.sh:141-149`:

```bash
tarball_sha256sum="$(
  curl ... | grep -F "  ./${tarball_name}"
)"

if [[ -z ${tarball_sha256sum} ]] \
  || ! _bx::update::check_checksum ...; then
  _bx::update::abort "Download corrupted ...!"
fi
```

The assignment runs in the main shell, so `set -e` + `pipefail` abort the script when `grep` finds nothing. The "Download corrupted" check is unreachable for the empty case. Reproduced with a fake `curl`:

```
bx-update: Downloading bx 99.0.0...
status=1          # no error line
```

Wrap the assignment in `if ! ...; then abort ...; fi` (or append `|| true` and test emptiness).

### 1.4 [DONE] `install.sh` has the same pattern

`install.sh:82-88` assigns `tarball_sha256sum` the same way, so a missing checksum exits silently before the `check_checksum` error path. The tarball download (`install.sh:80`) also relies on curl's message with no `install.sh:` context.

### 1.5 [DONE] `bx --list` with zero recipes succeeds silently (minor)

`src/recipe_registry.sh:41-42` returns without output; `bx` itself correctly aborts with `No recipes!`, but `bx --list` exits 0 with empty stdout. Debatable, but worth a decision.

---

## 2. Errors pointing at internal code

### 2.1 [DONE] Missing option value leaks `set -u` (high severity)

`src/cli.sh:99-102` reads `$2` without checking it exists:

```
$ ./bin/bx -f
/Users/adrien/projects/bx/src/cli.sh: line 100: $2: unbound variable
status=1
```

Same for `--file` and `--bashfile`. `--bashfile=` (empty) instead produces the misleading `bx: No Bashfile!`. These should be `bx: Option '-f' requires an argument!`.

### 2.2 [DONE] Malformed invocations leak the parser internals (high severity)

`src/recipe.sh:61-70` parses the invocation with `eval`:

```bash
eval "invocation+=($1)"
```

Any quoting mistake in `bx '...'` surfaces internal lines:

```
$ ./bin/bx 'r "'
/…/src/recipe.sh: eval: line 69: unexpected EOF while looking for matching `"'
/…/src/recipe.sh: eval: line 70: syntax error: unexpected end of file

$ ./bin/bx 'r )'
/…/src/recipe.sh: eval: line 69: syntax error near unexpected token `)'
/…/src/recipe.sh: line 71: invocation[0]: unbound variable
```

This also means the invocation string is evaluated **twice** — once for canonicalization, once for execution. Verified: `bx 'r $(echo SIDE-EFFECT >&2)'` runs the substitution twice and passes the expanded value, not the literal. That is both a surprise side effect and a robustness/security concern.

Recommended fix: parse once into an array, abort with ``bx: Invalid recipe invocation `...`!`` on parse failure, build the canonical trace from the array, and invoke `"${invocation[@]}"` directly. This removes the internal leak and the double evaluation. It slightly narrows accepted syntax (no redirections or compound commands inside an invocation), which is consistent with the documented "recipe plus arguments" model and not covered by tests.

### 2.3 [IGNORE] Internal failures have no safety net (low-medium)

`bin/bx:21` and `src/main.sh` trust that every internal file exists, and `src/main.sh` has no `trap`. A corrupted install or an unexpected internal `set -u` failure leaks lines like `bin/bx: line 21: … No such file or directory` with no bx context. Not user-triggerable in a healthy install, but easy to harden.

---

## 3. Insufficient or misleading diagnostics

| Location | Problem | Suggested |
|---|---|---|
| `src/bashfile.sh:47-51` | `No Bashfile!` is used for "not found by lookup", missing `-f` path, and `-f` pointing at a directory | Distinguish ``Bashfile not found: <path>`` from ``No Bashfile found from <cwd>`` |
| `src/annotations/default.sh:7-15` | `Too many default recipes!` names neither recipe | Include both annotation-stack recipes |
| `src/main.sh`, `src/bashfile.sh` | A Bashfile syntax error exits 2 with a correct user-file location but no `bx:` context | Add ``bx: Failed to load Bashfile `<path>`.`` |
| `dist.bashfile:20,76` | `basename "${SHELL}"` under `set -u` leaks `dist.bashfile: line 20: SHELL: unbound variable` | Use `${SHELL:-}` and abort with a message |
| `install.sh:17-19` | Unlike `src/display.sh`, `tput` failures are not suppressed | Add `2>/dev/null \|\| true` |
| `src/main.sh:69-73` | Good precedent: detects an unsupported `BASH_XTRACEFD` and explains | Keep; use as the style model |

---

## Proposed remediation plan

### Phase 1 — [DONE] Stop silent failures and internal leaks

1. `src/cli.sh`: validate `-f` / `--file` / `--bashfile` arguments; reject empty values; abort with a bx message.
2. `src/overrides.sh`: narrow the stderr redirect to the quiet-mode `builtin set +x`, detect `builtin set` failure, and emit `bx: Invalid shell option: ...` instead of leaking `overrides.sh`.
3. `src/recipe.sh`: replace the two-eval invocation path with a single parse into an array; abort on malformed input with ``bx: Invalid recipe invocation ...``; preserve canonical trace output (existing quoting and single-quote tests must keep passing).
4. `src/subcommands/update.sh` and `install.sh`: guard checksum and version command substitutions so failures reach the existing `abort` / `error` paths.
5. `bin/bx` / `src/main.sh`: optionally guard missing internal files with an installation-corrupted message.

### Phase 2 — Consistent failure reporting

6. Add an `EXIT` trap in `_bx::main` that:
   - closes any trace frames still on `__BX_INVOCATION_STACK__` (fixes unbalanced traces, including `exit N` in a recipe and nested failures);
   - prints a bx-prefixed summary when status is non-zero and no bx message was already printed, e.g. ``bx: Recipe `f` failed (status 1).`` or `bx: Failed to load Bashfile ...`;
   - leaves the original exit status untouched.
7. Add a small `_bx::error` helper and an "already reported" flag so `_bx::abort` and the trap never print duplicate messages.

### Phase 3 — Messages, docs, tests

8. Improve the `No Bashfile!`, `Too many default recipes!`, and `SHELL` diagnostics.
9. Update `README.md`, `man/man1/bx.1` (EXIT STATUS), and `CHANGELOG.md` (`[Unreleased]`).
10. Add or adjust Cucumber scenarios:
    - `features/bashfile.feature`: missing or empty `-f` value, missing explicit path.
    - `features/recipe__failure_handling.feature`: plain `false` failure, `return N`, nested failure, balanced traces, summary line, exit status.
    - `features/recipe__arguments.feature`: malformed quoting, single evaluation of `$(...)`, empty invocation.
    - `features/recipe__shell_options.feature`: invalid `set` option surfaces an error; quiet-mode `set -x` remains silent.
    - `features/recipe__validation.feature`: Bashfile load-failure context (if implemented).
11. Run `./bin/bx format lint man::lint features::lint` and `./bin/bx features::check` (macOS + Bash 3.2 locally; CI also runs Ubuntu). No subcommand test harness exists today; hardening `bx-update` / `install.sh` may need a small shell-level feature or manual verification.

---

## Open decisions

1. **Recipe failure output**
   - Always add a bx summary (recommended): e.g. ``bx: Recipe `r` failed (status 1).`` for every non-zero exit, including `command not found`. Makes the man page's bx-prefixed guarantee true and removes silent `false` failures. Requires updating existing failure-handling test expectations.
   - Only balance traces: close open trace braces on failure and preserve exit status, but add no bx summary. User code that fails silently stays silent.
   - Only when nothing else printed: add a summary only when the failure produced no stderr at all. Requires capturing or tracking user stderr, which is more invasive in Bash 3.2.

2. **Invocation parsing**
   - Parse once and invoke the array (recommended): removes internal `src/recipe.sh` errors, double command-substitution side effects, and unbound-array errors. Slight behavior narrowing: invocation strings become recipe plus arguments, not arbitrary shell snippets.
   - Minimal error translation: keep the existing double eval but catch failures and print a bx-prefixed error. Stops internal paths leaking, but keeps double evaluation and is harder to make reliable.

3. **Message wording**
   - Yes, update wording (recommended): distinguish lookup failure from an explicit missing `-f` path, name conflicting `@default` recipes, and guard `$SHELL` in `dist.bashfile`. Requires updating a few feature expectations and docs.
   - No, keep current wording: focus only on silent failures, internal-code leaks, and balanced traces.

## Verification notes

- Findings 1.1, 1.2, 1.3, 1.5, 2.1, and 2.2 were reproduced directly.
- Finding 1.4 follows the same code path as 1.3; `install.sh` is a build template and was reviewed statically.
- If a fix is implemented, run the checks listed in Phase 3 step 11 and report their outcome.
