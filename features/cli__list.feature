Feature: CLI--List

  Scenario Outline: List available recipes
    Given the Bashfile
      ```bash
      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    When setting
      | OPTION        |
      | <LIST OPTION> |
    And invoking
    Then bx outputs to stdout
      """
      Available recipes:
          recipe-1
              A short description of recipe-1.
          recipe-2
      """
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
    When setting
      | OPTION |
      | -l     |
    And invoking
    Then bx outputs to stdout
      """
      Available recipes:
          recipe-1
              A short description of recipe-1
              that continues on multiple lines.
          recipe-2
              A short description of recipe-2
              that continues on multiple lines.
      """
    And bx succeeds

  Scenario: List available recipes with empty help
    Given the Bashfile
      ```bash
      recipe-1() {
        @help
      }

      recipe-2() { :; }
      ```
    When setting
      | OPTION |
      | -l     |
    And invoking
    Then bx outputs to stdout
      """
      Available recipes:
          recipe-1
          recipe-2
      """
    And bx succeeds

  Scenario: List available recipes when there are none
    Given an empty Bashfile
    When setting
      | OPTION |
      | -l     |
    And invoking
    Then bx outputs nothing to stdout
    And bx does not error out
    And bx succeeds

  Scenario: Ask for available recipes from uninitialized bx environment
    Given no Bashfile
    When setting
      | OPTION |
      | -l     |
    And invoking
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT   | CONTENT      |
      | bx-error | No Bashfile! |
    And bx fails
