Feature: CLI--Completion List

  Scenario: List recipes
    Given the Bashfile
      ```bash
      default() { @default; }

      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    When setting
      | OPTION            |
      | --completion-list |
    And invoking
    Then bx outputs to stdout
      """
      default
      recipe-1
      recipe-2
      """
    And bx succeeds

  Scenario: List available recipes when there are none
    Given an empty Bashfile
    When setting
      | OPTION            |
      | --completion-list |
    And invoking
    Then bx outputs nothing to stdout
    And bx outputs nothing to stderr
    And bx succeeds
