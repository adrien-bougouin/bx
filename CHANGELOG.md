# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.13.0] - 2026-10-26
### Added
- Distribute `CHANGELOG.md` together with the release.

## [0.12.0] - 2026-10-25
### Changed
- `bx`, `bx-update`, `bx-uninstall`, the installer, and internal scripts now use `/usr/bin/env bash` instead of `/bin/bash`, so the Bash found on `PATH` is used.

## [0.11.1] - 2026-10-22
### Changed
- Corrected the `--help` description in `bx(1)` so it no longer claims that recipes are listed.

## [0.11.0] - 2026-10-21
### Changed
- Simplified recipe traces by removing the `# ` separator: traces now look like `+ recipe {` instead of `+ # recipe {`.

## [0.10.2] - 2026-10-20
### Changed
- Reformatted and clarified `bx(1)`.

## [0.10.1] - 2026-10-19
### Changed
- Documented the annotation-placement rule and its error message in `bx(1)`.

## [0.10.0] - 2026-10-19
### Added
- Validate that annotations appear before executable code in a recipe body.
  A misplaced annotation now aborts Bashfile loading, even when a different recipe is invoked.

### Fixed
- Made annotation-start detection compatible with stricter glibc regular-expression behavior.

## [0.9.0] - 2026-10-16
### Fixed
- Prevented glob expansion in `@help` descriptions when listing recipes.

## [0.8.0] - 2026-10-16
### Fixed
- Recipe traces now render arguments with shell-safe quoting so they can be copied and re-run.

## [0.7.0] - 2026-10-15
### Changed
- `bx --list` now marks default and confirmation-required recipes with `[@default]` and `[@confirm]`.

## [0.6.12] - 2026-10-15
### Changed
- `bx-update` now runs update logic shipped with the installation, no longer downloads a separate `update.sh`, and verifies the downloaded archive against `SHA256SUMS`.

## [0.6.11] - 2026-10-14
### Changed
- The installer verifies the downloaded archive against the release's `SHA256SUMS`.

## [0.6.9] - 2026-10-13
### Changed
- `bx-update` now uses a locally installed updater that resolves the latest release and runs that release's updater.

## [0.6.8] - 2026-10-12
### Changed
- `bx-uninstall` now uninstalls from the local installation without downloading `uninstall.sh`.

### Fixed
- Corrected the local uninstaller's source path.

## [0.6.7] - 2026-10-09
### Changed
- Documented recipe traces, private functions, reserved names, and quiet-mode `set` behavior in `bx(1)`.

## [0.6.6] - 2026-10-06
### Fixed
- `bx::invoke` only treats an exact `-y` or `--yes` argument as auto-confirm; recipe names containing those strings are no longer affected.

## [0.6.4] - 2026-10-06
### Fixed
- ANSI styling is now emitted only when stdout and stderr are terminals.

## [0.6.3] - 2026-10-06
### Changed
- `--help` no longer loads the Bashfile or lists recipes; use `--list` to list recipes.

## [0.6.2] - 2026-10-05
### Fixed
- `bx --version` no longer loads or executes the Bashfile.

## [0.6.1] - 2026-10-04
### Changed
- Clarified installer, updater, and uninstaller messages; `bx-update` now fails when the installed version cannot be determined.

## [0.6.0] - 2026-10-03
### Added
- `bx-uninstall` command.

## [0.5.1] - 2026-10-02
### Changed
- Documented `bx-update` in `bx(1)`.

## [0.5.0] - 2026-10-02
### Added
- `bx-update` command and update script for updating an existing installation.

## [0.4.2] - 2026-09-13
### Fixed
- Circular invocation detection now canonicalizes invocations, so equivalent formatting such as `"a b"` and `a\ b` is recognized as the same invocation.
- `bx` now preserves its original `errexit` shell option correctly.

## [0.4.1] - 2026-09-09
### Changed
- Improved annotation parsing performance.

## [0.4.0] - 2026-09-09
### Fixed
- Recipe isolation now restores `shopt` options as well as `set` options.

## [0.3.1] - 2026-09-08
### Added
- `bx::invoke -y` / `--yes` to temporarily auto-confirm nested recipes that require confirmation.

## [0.3.0] - 2026-09-07
### Added
- `-y` / `--yes` option to automatically confirm recipes that require confirmation.

### Fixed
- Argument forwarding for recipe arguments containing spaces, such as `--arg="arg 1"`.

## [0.2.2] - 2026-09-02
### Fixed
- Recipe invocation messages now use backticks, avoiding quote conflicts in errors and warnings.

## [0.2.1] - 2026-09-01
### Fixed
- Prevented `bx::invoke` from invoking the default recipe when called without arguments.

## [0.2.0] - 2026-09-01
### Added
- `@confirm` annotation for interactive `[y/N]` confirmation before a recipe is invoked.

## [0.1.2] - 2026-08-28
### Added
- Added the `bx(1)` manual page.

## [0.1.1] - 2026-08-27
### Added
- MIT License.

## [0.1.0] - 2026-08-27
Initial release.

### Added
- Bashfile discovery, including upward lookup from the current directory.
- Bash functions as recipes, with private `_`-prefixed functions and reserved `bx`/`bx::*` names excluded.
- Recipe chaining and quoted recipe arguments.
- `@help` and `@default` annotations.
- Nested recipe invocation with `bx::invoke`.
- Circular invocation prevention.
- Recipe-level tracing using a prefix consistent with `PS4`.
- Shell option isolation between recipes and from `bx`.
- Scope boundaries: function recipes share scope, while subprocess recipes operate in a fork.
- Options: `-f`/`--file`/`--bashfile`, `-h`/`--help`, `-l`/`--list`, `-q`/`--quiet`, `-v`/`--version`, and `--`.

[Unreleased]: https://github.com/adrien-bougouin/bx/compare/v0.13.0...HEAD
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
