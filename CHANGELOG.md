# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.16.2] - 2026-11-11
### Fixed
- Abort with an error when `-f`/`--file`/`--bashfile` is missing a value, instead of leaking internal errors.
- Abort with an error when a recipe invocation cannot be parsed, instead of leaking internal errors.

## [0.16.1] - 2026-11-10
### Fixed
- Prevent hidden `set` failures.
- Prevent `install.sh` and `bx-update` from exiting silently when checksum verification fails.
- Make `bx --list` fail with `No recipes!` when the Bashfile defines no recipes.

## [0.16.0] - 2026-11-07
### Added
- Make `bx-update` display the release notes added since the previously installed version.

### Changed
- Update `install.sh`, `bx-update` and `bx-uninstall` messages to use `install.sh:`, `bx-update:` and `bx-uninstall:` prefixes instead of `bx-installer:`, `bx-updater:` and `bx-uninstaller:`.

## [0.15.0] - 2026-11-06
### Added
- Support the `BX_RECIPE_TRACE=0` environment variable to disable recipe traces by default.

## [0.14.0] - 2026-11-05
### Changed
- Improve portability by removing the `realpath` dependency.

## [0.13.1] - 2026-10-28
### Changed
- Reformat `bx --list` to include the sourced Bashfile path.

## [0.13.0] - 2026-10-26
### Added
- Distribute `CHANGELOG.md` together with the release.

## [0.12.0] - 2026-10-25
### Changed
- Use `/usr/bin/env bash` instead of `/bin/bash` in `bx`, `bx-update`, `bx-uninstall`, the installer, and internal scripts, so the Bash found on `PATH` is used.

## [0.11.1] - 2026-10-22
### Changed
- Correct the `--help` description in `bx(1)` so it no longer claims that recipes are listed.

## [0.11.0] - 2026-10-21
### Changed
- Simplify recipe traces by removing the `# ` separator: traces now look like `+ recipe {` instead of `+ # recipe {`.

## [0.10.2] - 2026-10-20
### Changed
- Reformat and clarify `bx(1)`.

## [0.10.1] - 2026-10-19
### Changed
- Document the annotation-placement rule and its error message in `bx(1)`.

## [0.10.0] - 2026-10-19
### Added
- Validate that annotations appear before executable code in a recipe body and abort Bashfile loading on a misplaced annotation, even when a different recipe is invoked.

### Fixed
- Make annotation-start detection compatible with stricter glibc regular-expression behavior.

## [0.9.0] - 2026-10-16
### Fixed
- Prevent glob expansion in `@help` descriptions when listing recipes.

## [0.8.0] - 2026-10-16
### Fixed
- Make recipe traces render arguments with shell-safe quoting so they can be copied and re-run.

## [0.7.0] - 2026-10-15
### Changed
- Mark default and confirmation-required recipes with `[@default]` and `[@confirm]` in `bx --list`.

## [0.6.12] - 2026-10-15
### Changed
- Run update logic shipped with the installation in `bx-update`, stop downloading a separate `update.sh`, and verify the downloaded archive against `SHA256SUMS`.

## [0.6.11] - 2026-10-14
### Changed
- Make the installer verify the downloaded archive against the release's `SHA256SUMS`.

## [0.6.9] - 2026-10-13
### Changed
- Make `bx-update` use a locally installed updater that resolves the latest release and runs that release's updater.

## [0.6.8] - 2026-10-12
### Changed
- Make `bx-uninstall` uninstall from the local installation without downloading `uninstall.sh`.

### Fixed
- Correct the local uninstaller's source path.

## [0.6.7] - 2026-10-09
### Changed
- Document recipe traces, private functions, reserved names, and quiet-mode `set` behavior in `bx(1)`.

## [0.6.6] - 2026-10-06
### Fixed
- Treat only an exact `-y` or `--yes` argument as auto-confirm in `bx::invoke`, so recipe names containing those strings are not affected.

## [0.6.4] - 2026-10-06
### Fixed
- Emit ANSI styling only when stdout and stderr are terminals.

## [0.6.3] - 2026-10-06
### Changed
- Stop loading the Bashfile or listing recipes for `--help`; use `--list` to list recipes.

## [0.6.2] - 2026-10-05
### Fixed
- Stop loading or executing the Bashfile for `bx --version`.

## [0.6.1] - 2026-10-04
### Changed
- Clarify installer, updater, and uninstaller messages; make `bx-update` fail when the installed version cannot be determined.

## [0.6.0] - 2026-10-03
### Added
- Add the `bx-uninstall` command.

## [0.5.1] - 2026-10-02
### Changed
- Document `bx-update` in `bx(1)`.

## [0.5.0] - 2026-10-02
### Added
- Add the `bx-update` command and update script for updating an existing installation.

## [0.4.2] - 2026-09-13
### Fixed
- Make circular invocation detection canonicalize invocations, so equivalent formatting such as `"a b"` and `a\ b` is recognized as the same invocation.
- Preserve the original `errexit` shell option in `bx`.

## [0.4.1] - 2026-09-09
### Changed
- Improve annotation parsing performance.

## [0.4.0] - 2026-09-09
### Fixed
- Make recipe isolation restore `shopt` options as well as `set` options.

## [0.3.1] - 2026-09-08
### Added
- Add `bx::invoke -y` / `--yes` to temporarily auto-confirm nested recipes that require confirmation.

## [0.3.0] - 2026-09-07
### Added
- Add the `-y` / `--yes` option to automatically confirm recipes that require confirmation.

### Fixed
- Forward recipe arguments containing spaces, such as `--arg="arg 1"`.

## [0.2.2] - 2026-09-02
### Fixed
- Use backticks in recipe invocation messages to avoid quote conflicts in errors and warnings.

## [0.2.1] - 2026-09-01
### Fixed
- Prevent `bx::invoke` from invoking the default recipe when called without arguments.

## [0.2.0] - 2026-09-01
### Added
- Add the `@confirm` annotation for interactive `[y/N]` confirmation before a recipe is invoked.

## [0.1.2] - 2026-08-28
### Added
- Add the `bx(1)` manual page.

## [0.1.1] - 2026-08-27
### Added
- Add the MIT License.

## [0.1.0] - 2026-08-27
Initial release.

### Added
- Discover Bashfiles, including upward lookup from the current directory.
- Treat Bash functions as recipes, excluding private `_`-prefixed functions and reserved `bx`/`bx::*` names.
- Support recipe chaining and quoted recipe arguments.
- Add `@help` and `@default` annotations.
- Invoke nested recipes with `bx::invoke`.
- Prevent circular invocations.
- Trace recipes using a prefix consistent with `PS4`.
- Isolate shell options between recipes and from `bx`.
- Keep function recipes in the same scope and run subprocess recipes in a fork.
- Support the `-f`/`--file`/`--bashfile`, `-h`/`--help`, `-l`/`--list`, `-q`/`--quiet`, `-v`/`--version`, and `--` options.

[Unreleased]: https://github.com/adrien-bougouin/bx/compare/v0.16.2...HEAD
[0.16.2]: https://github.com/adrien-bougouin/bx/compare/v0.16.1...v0.16.2
[0.16.1]: https://github.com/adrien-bougouin/bx/compare/v0.16.0...v0.16.1
[0.16.0]: https://github.com/adrien-bougouin/bx/compare/v0.15.0...v0.16.0
[0.15.0]: https://github.com/adrien-bougouin/bx/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/adrien-bougouin/bx/compare/v0.13.1...v0.14.0
[0.13.1]: https://github.com/adrien-bougouin/bx/compare/v0.13.0...v0.13.1
[0.13.0]: https://github.com/adrien-bougouin/bx/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/adrien-bougouin/bx/compare/v0.11.1...v0.12.0
[0.11.1]: https://github.com/adrien-bougouin/bx/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/adrien-bougouin/bx/compare/v0.10.2...v0.11.0
[0.10.2]: https://github.com/adrien-bougouin/bx/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/adrien-bougouin/bx/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/adrien-bougouin/bx/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/adrien-bougouin/bx/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/adrien-bougouin/bx/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/adrien-bougouin/bx/compare/v0.6.12...v0.7.0
[0.6.12]: https://github.com/adrien-bougouin/bx/compare/v0.6.11...v0.6.12
[0.6.11]: https://github.com/adrien-bougouin/bx/compare/v0.6.9...v0.6.11
[0.6.9]: https://github.com/adrien-bougouin/bx/compare/v0.6.8...v0.6.9
[0.6.8]: https://github.com/adrien-bougouin/bx/compare/v0.6.7...v0.6.8
[0.6.7]: https://github.com/adrien-bougouin/bx/compare/v0.6.6...v0.6.7
[0.6.6]: https://github.com/adrien-bougouin/bx/compare/v0.6.4...v0.6.6
[0.6.4]: https://github.com/adrien-bougouin/bx/compare/v0.6.3...v0.6.4
[0.6.3]: https://github.com/adrien-bougouin/bx/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/adrien-bougouin/bx/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/adrien-bougouin/bx/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/adrien-bougouin/bx/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/adrien-bougouin/bx/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/adrien-bougouin/bx/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/adrien-bougouin/bx/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/adrien-bougouin/bx/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/adrien-bougouin/bx/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/adrien-bougouin/bx/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/adrien-bougouin/bx/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/adrien-bougouin/bx/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/adrien-bougouin/bx/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/adrien-bougouin/bx/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/adrien-bougouin/bx/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/adrien-bougouin/bx/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/adrien-bougouin/bx/releases/tag/v0.1.0
