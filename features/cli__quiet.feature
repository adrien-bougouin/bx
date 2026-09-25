Feature: CLI--Quiet

  Scenario Outline: Invoke a recipe in quiet mode
    Given the Bashfile
      ```bash
      recipe() {
        echo "Recipe was invoked!!!"
      }
      ```
    When setting
      | OPTION         |
      | <QUIET OPTION> |
    And invoking
      | RECIPE |
      | recipe |
    Then bx outputs to stdout
      """
      Recipe was invoked!!!
      """
    And bx outputs nothing to stderr
    And bx succeeds

    Examples:
      | QUIET OPTION |
      | -q           |
      | --quiet      |

  Scenario: Invoke a recipe in quiet mode when xtrace is enabled
    Given the Bashfile
      ```bash
      recipe() {
        set -x

        echo "Recipe was invoked!!!"
      }
      ```
    When setting
      | OPTION |
      | -q     |
    And invoking
      | RECIPE |
      | recipe |
    Then bx outputs to stdout
      """
      Recipe was invoked!!!
      """
    And bx outputs nothing to stderr
    And bx succeeds
