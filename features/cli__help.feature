Feature: CLI--Help

  Scenario Outline: Ask bake for help when there are no recipes to document
    Given the Bakefile
      ```bash
      ```
    When running `bake` with arguments "<HELP OPTION>"
    Then bake does not error out
    And bake displays
      """
      Usage: bake [options] [--] [recipe] ...

      Options:
          -f FILE, --file FILE, --bakefile FILE
             Read FILE as a bakefile.
          -h, --help
             Show this help.
          -l, --list
             Show the available recipes.
          -s, --silent, -q, --quiet
             Do not display the executed recipe name and arguments.
          -v, --version
             Show version.
      """

    Examples:
      | HELP OPTION |
      | -h          |
      | --help      |

  Scenario Outline: Ask bake for help when there are recipes to document
    Given the Bakefile
      ```bash
      recipe-1() { :; }

      recipe-2() { :; }
      ```
    When running `bake` with arguments "<HELP OPTION>"
    Then bake displays
      """
      Usage: bake [options] [--] [recipe] ...

      Options:
          -f FILE, --file FILE, --bakefile FILE
             Read FILE as a bakefile.
          -h, --help
             Show this help.
          -l, --list
             Show the available recipes.
          -s, --silent, -q, --quiet
             Do not display the executed recipe name and arguments.
          -v, --version
             Show version.

      Available recipes:
          recipe-1
          recipe-2
      """
    And bake does not error out

    Examples:
      | HELP OPTION |
      | -h          |
      | --help      |
