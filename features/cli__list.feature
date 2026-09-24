Feature: CLI--List

  Scenario Outline: List available recipes
    Given the Bashfile
      ```bash
      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    When setting options
      | <LIST OPTION> |
    And invoking
    Then bx displays
      """
      Available recipes:
          recipe-1
              A short description of recipe-1.
          recipe-2
      """
    And bx does not error out
    And bx succeeds

    Examples:
      | LIST OPTION |
      | -l          |
      | --list      |

  Scenario: List available recipes with multi-line help
    Given the Bashfile
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
    When setting options
      | -l |
    And invoking
    Then bx displays
      """
      Available recipes:
          recipe-1
              A short description of recipe-1
              that continues on multiple lines.
          recipe-2
              A short description of recipe-2
              that continues on multiple lines.
      """
    And bx does not error out
    And bx succeeds

  Scenario: List available recipes with empty help
    Given the Bashfile
      ```bash
      recipe-1() {
        @help
      }

      recipe-2() { :; }
      ```
    When setting options
      | -l |
    And invoking
    Then bx displays
      """
      Available recipes:
          recipe-1
          recipe-2
      """
    And bx does not error out
    And bx succeeds

  Scenario: List available recipes when there are none
    Given an empty Bashfile
    When setting options
      | -l |
    And invoking
    Then bx displays nothing
    And bx does not error out
    And bx succeeds

  Scenario: Ask for available recipes from uninitialized bx environment
    Given no Bashfile
    When setting options
      | -l |
    And invoking
    Then bx displays nothing
    And bx errors out with message "bx: No Bashfile!"
    And bx fails
