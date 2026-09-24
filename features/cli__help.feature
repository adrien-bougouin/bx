Feature: CLI--Help

  Scenario Outline: Ask for help
    Given an empty Bashfile
    When setting
      | OPTION        |
      | <HELP OPTION> |
    And invoking
    Then bx outputs
      | TYPE    | DATA                                                                 |
      | bx-help | Usage: bx [options] [--] [recipe] ...                                |
      | bx-help |                                                                      |
      | bx-help | Options:                                                             |
      | bx-help | %%-f FILE, --file=FILE, --bashfile=FILE                              |
      | bx-help | %%%%Read FILE as a bashfile. Only one bashfile may be specified.     |
      | bx-help | %%-h, --help                                                         |
      | bx-help | %%%%Show this help.                                                  |
      | bx-help | %%-l, --list                                                         |
      | bx-help | %%%%Show the available recipes.                                      |
      | bx-help | %%-q, --quiet                                                        |
      | bx-help | %%%%Do not display the invoked recipe traces, nor the xtrace output. |
      | bx-help | %%-v, --version                                                      |
      | bx-help | %%%%Show version.                                                    |
      | bx-help | %%-y, --yes                                                          |
      | bx-help | %%%%Do not ask for confirmation before invoking a recipe             |
      | bx-help | %%%%(automatically confirm).                                         |
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
    Then bx outputs
      | TYPE    | DATA                                                                 |
      | bx-help | Usage: bx [options] [--] [recipe] ...                                |
      | bx-help |                                                                      |
      | bx-help | Options:                                                             |
      | bx-help | %%-f FILE, --file=FILE, --bashfile=FILE                              |
      | bx-help | %%%%Read FILE as a bashfile. Only one bashfile may be specified.     |
      | bx-help | %%-h, --help                                                         |
      | bx-help | %%%%Show this help.                                                  |
      | bx-help | %%-l, --list                                                         |
      | bx-help | %%%%Show the available recipes.                                      |
      | bx-help | %%-q, --quiet                                                        |
      | bx-help | %%%%Do not display the invoked recipe traces, nor the xtrace output. |
      | bx-help | %%-v, --version                                                      |
      | bx-help | %%%%Show version.                                                    |
      | bx-help | %%-y, --yes                                                          |
      | bx-help | %%%%Do not ask for confirmation before invoking a recipe             |
      | bx-help | %%%%(automatically confirm).                                         |
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
    Then bx outputs
      | TYPE   | DATA                                                                  |
      | bx-help | Usage: bx [options] [--] [recipe] ...                                |
      | bx-help |                                                                      |
      | bx-help | Options:                                                             |
      | bx-help | %%-f FILE, --file=FILE, --bashfile=FILE                              |
      | bx-help | %%%%Read FILE as a bashfile. Only one bashfile may be specified.     |
      | bx-help | %%-h, --help                                                         |
      | bx-help | %%%%Show this help.                                                  |
      | bx-help | %%-l, --list                                                         |
      | bx-help | %%%%Show the available recipes.                                      |
      | bx-help | %%-q, --quiet                                                        |
      | bx-help | %%%%Do not display the invoked recipe traces, nor the xtrace output. |
      | bx-help | %%-v, --version                                                      |
      | bx-help | %%%%Show version.                                                    |
      | bx-help | %%-y, --yes                                                          |
      | bx-help | %%%%Do not ask for confirmation before invoking a recipe             |
      | bx-help | %%%%(automatically confirm).                                         |
      | bx-help |                                                                      |
      | bx-help | Available recipes:                                                   |
      | bx-help | %%recipe-1                                                           |
      | bx-help | %%%%A short description of recipe-1.                                 |
      | bx-help | %%recipe-2                                                           |
    And bx succeeds
