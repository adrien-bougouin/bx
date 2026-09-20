Feature: CLI--Quiet

  Scenario Outline: Invoke a recipe in quiet mode
    Given the Bashfile
      ```bash
      recipe() {
        echo "Recipe was invoked!!!"
      }
      ```
    When setting options
      | <QUIET OPTION> |
    And invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | TYPE   | DATA                  |
      | stdout | Recipe was invoked!!! |
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
    When setting options
      | -q |
    And invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | TYPE   | DATA                  |
      | stdout | Recipe was invoked!!! |
    And bx succeeds
