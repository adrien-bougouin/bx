Feature: CLI--List

  Scenario Outline: List available recipes
    Given the Bakefile
      ```bash
      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    When executing Bake with "<LIST OPTION>"
    Then Bake displays
      """
      Available recipes:
          recipe-1
              A short description of recipe-1.
          recipe-2
      """
    And Bake does not error out

    Examples:
      | LIST OPTION |
      | -l          |
      | --list      |

  Scenario: List available recipes with multi-line help
    Given the Bakefile
      ```bash
      recipe-1() {
        @help "A short description of recipe-1" \
          "that continues on multiple lines."
      }

      recipe-2() {
        @help "A short description of recipe-2" \
          "that continues on multiple lines."
      }
      ```
    When executing Bake with "-l"
    Then Bake displays
      """
      Available recipes:
          recipe-1
              A short description of recipe-1
              that continues on multiple lines.
          recipe-2
              A short description of recipe-2
              that continues on multiple lines.
      """
    And Bake does not error out

  Scenario: List available recipes with empty help
    Given the Bakefile
      ```bash
      recipe-1() {
        @help
      }

      recipe-2() { :; }
      ```
    When executing Bake with "-l"
    Then Bake displays
      """
      Available recipes:
          recipe-1
          recipe-2
      """
    And Bake does not error out

  Scenario: List available recipes when there are none
    Given an empty Bakefile
    When executing Bake with "-l"
    Then Bake displays nothing
    And Bake does not error out
