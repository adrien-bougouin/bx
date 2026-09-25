Feature: CLI--Help

  Scenario Outline: Ask for help
    Given an empty Bashfile
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

  Scenario: Ask for help from uninitialized bx environment
    Given no Bashfile
    When setting
      | OPTION |
      | -h     |
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

  Scenario: Ask for help when there are recipes to document
    Given the Bashfile
      ```bash
      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    When setting
      | OPTION |
      | -h     |
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

      Available recipes:
          recipe-1
              A short description of recipe-1.
          recipe-2
      """
    And bx succeeds
