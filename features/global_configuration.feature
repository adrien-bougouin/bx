Feature: Global Configuration

  Background:
    Given the Bashfile
      ```bash
      recipe() {
        set -x

        echo "Recipe invoked!"
      }
      ```

  Scenario: Disable recipe traces by default
    Given the shell environment
      ```bash
      export BX_RECIPE_TRACE=0
      ```
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs to stdout
      """
      Recipe invoked!
      """
    And bx outputs to stderr
      | FORMAT | CONTENT                |
      | xtrace | echo 'Recipe invoked!' |
    And bx succeeds

  Scenario: Keep recipe traces with any other value
    Given the shell environment
      ```bash
      export BX_RECIPE_TRACE=1
      ```
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs to stdout
      """
      Recipe invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                |
      | bx-trace-in  | recipe                 |
      | xtrace       | echo 'Recipe invoked!' |
      | bx-trace-out |                        |
    And bx succeeds
