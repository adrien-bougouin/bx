Feature: CLI--List

  Scenario Outline: Ask Bake for the list of available recipes
    Given the Bakefile
      ```bash
      recipe-1() { :; }

      recipe-2() { :; }
      ```
    When executing Bake with arguments "<LIST OPTION>"
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

  Scenario Outline: Ask Bake for the list of available recipes when there are none
    Given the Bakefile
      ```bash
      ```
    When executing Bake with arguments "<LIST OPTION>"
    Then Bake displays nothing
    And Bake does not error out

    Examples:
      | LIST OPTION |
      | -l          |
      | --list      |
