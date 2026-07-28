Feature: CLI--Help

  Scenario Outline: Ask for help
    Given an empty Bakefile
    When executing Bake with "<HELP OPTION>"
    Then Bake displays
      """
      Usage: bake [options] [--] [recipe] ...

      Options:
          -f FILE, --file FILE, --bakefile FILE
             Read FILE as a bakefile. Only one bakefile may be specified.
          -h, --help
             Show this help.
          -l, --list
             Show the available recipes.
          -s, --silent, -q, --quiet
             Do not display the invoked recipe name and arguments.
          -v, --version
             Show version.
      """
    And Bake does not error out

    Examples:
      | HELP OPTION |
      | -h          |
      | --help      |

  Scenario Outline: Ask for help when there are recipes to document
    Given the Bakefile
      ```bash
      recipe-1() { :; }

      recipe-2() { :; }
      ```
    When executing Bake with "<HELP OPTION>"
    Then Bake displays
      """
      Usage: bake [options] [--] [recipe] ...

      Options:
          -f FILE, --file FILE, --bakefile FILE
             Read FILE as a bakefile. Only one bakefile may be specified.
          -h, --help
             Show this help.
          -l, --list
             Show the available recipes.
          -s, --silent, -q, --quiet
             Do not display the invoked recipe name and arguments.
          -v, --version
             Show version.

      Available recipes:
          recipe-1
          recipe-2
      """
    And Bake does not error out

    Examples:
      | HELP OPTION |
      | -h          |
      | --help      |
