Feature: CLI--Help

  Scenario Outline: Ask for help
    Given an empty Bashfile
    When executing bx with "<HELP OPTION>"
    Then bx displays
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
      """
    And bx does not error out

    Examples:
      | HELP OPTION |
      | -h          |
      | --help      |

  Scenario: Ask for help from uninitialized bx environment
    Given no Bashfile
    When executing bx with "-h"
    Then bx displays
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
      """
    And bx does not error out

  Scenario: Ask for help when there are recipes to document
    Given the Bashfile
      ```bash
      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    When executing bx with "-h"
    Then bx displays
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

      Available recipes:
          recipe-1
              A short description of recipe-1.
          recipe-2
      """
    And bx does not error out
