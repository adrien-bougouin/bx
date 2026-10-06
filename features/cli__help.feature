Feature: CLI--Help

  Scenario Outline: Ask for help
    When setting
      | OPTION        |
      | <HELP OPTION> |
    And invoking
    Then bx outputs to stdout
      """
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
      """
    And bx succeeds

    Examples:
      | HELP OPTION |
      | -h          |
      | --help      |
