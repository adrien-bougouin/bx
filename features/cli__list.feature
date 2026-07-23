Feature: CLI--List

  Scenario Outline: List available recipes
    Given the Bakefile
      ```bash
      recipe-1() { :; }

      recipe-2() { :; }
      ```
    When executing Bake with "<LIST OPTION>"
    Then Bake displays
      """
      Available recipes:
          recipe-1
          recipe-2
      """
    And Bake does not error out

    Examples:
      | LIST OPTION |
      | -l          |
      | --list      |

  Scenario Outline: List available recipes when there are none
    Given an empty Bakefile
    When executing Bake with "<LIST OPTION>"
    Then Bake displays nothing
    And Bake does not error out

    Examples:
      | LIST OPTION |
      | -l          |
      | --list      |
