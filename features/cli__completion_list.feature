Feature: CLI--Completion List

  Scenario: List all recipes
    Given the Bashfile
      ```bash
      default() { @default; }

      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    And the shell environment
      ```bash
      export BX_COMPLETE=1
      ```
    When invoking
    Then bx outputs to stdout
      """
      default
      recipe-1
      recipe-2
      """
    And bx succeeds

  Scenario: List only recipes matching prefix
    Given the Bashfile
      ```bash
      default() { @default; }

      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    And the shell environment
      ```bash
      export BX_COMPLETE=1
      ```
    When invoking recipe "re"
    Then bx outputs to stdout
      """
      recipe-1
      recipe-2
      """
    And bx succeeds

  Scenario: List only recipes matching prefix from a specific Bashfile
    Given the Bashfile at "another.bashfile"
      ```bash
      default() { @default; }

      recipe-1() {
        @help "A short description of recipe-1."
      }

      recipe-2() { :; }
      ```
    And the shell environment
      ```bash
      export BX_COMPLETE=1
      ```
    When setting
      | OPTION              |
      | -f another.bashfile |
    And invoking recipe "re"
    Then bx outputs to stdout
      """
      recipe-1
      recipe-2
      """
    And bx succeeds

  Scenario: List available recipes when there are none
    Given an empty Bashfile
    And the shell environment
      ```bash
      export BX_COMPLETE=1
      ```
    When invoking
    Then bx outputs nothing to stdout
    And bx outputs nothing to stderr
    And bx succeeds
