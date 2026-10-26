# Contributing to `bx`
Thanks for taking the time to contribute.
`bx` is intentionally small, and contributions that keep it that way are the most valuable.
First-time contributors are welcome.

## Scope
Read [VISION.md](VISION.md) before proposing a change.
`bx` is a thin layer around Bash and only adds features that improve recipe invocation.
If a change can live in a user's `Bashfile`, it probably does not belong in `bx`.
Prefer to open an issue before starting non-trivial work, and keep pull requests focused.

## Setup
Run `./bin/bx doctor` to check the setup for code and documentation formatting/linting.
Run `./bin/bx features::doctor` to check the setup for the test suite (which requires Ruby tools).

## Tests
Tests are Cucumber features in `features/`.
Run `./bin/bx features::check` to run the suite.
Ruby dependencies are installed automatically by the test recipe.
Add or update a scenario for every behavior change.

## Coding Style
Follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).
Keep the code compatible with Bash 3.2, the version shipped with macOS.
Run `./bin/bx format lint man::lint features::lint` before commiting and opening a pull request.

## Pull Requests
Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
Update `README.md` and `man/man1/bx.1` when user-facing behavior changes.

## License
`bx` is released under the [MIT License](LICENSE).
By submitting a contribution, you agree that it is licensed under the same terms, without additional conditions.
