Feature: CLI--List

  Scenario Outline: Ask `bake` for the list of available recipes
    Given the Bakefile
      ```bash
      recipe-1() { :; }

      recipe-2() { :; }
      ```
    When running `bake` with arguments "<LIST OPTION>"
    Then `bake` displays
      """
      Available recipes:
          recipe-1
          recipe-2
      """
    And `bake` does not error out

    Examples:
      | LIST OPTION |
      | -l          |
      | --list      |

  Scenario Outline: Ask `bake` for the list of available recipes when there are none
    Given the Bakefile
      ```bash
      ```
    When running `bake` with arguments "<LIST OPTION>"
    Then `bake` displays nothing
    And `bake` does not error out

    Examples:
      | LIST OPTION |
      | -l          |
      | --list      |
