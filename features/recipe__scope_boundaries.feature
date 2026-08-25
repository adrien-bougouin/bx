Feature: Recipe--Scope Boundaries

  Scenario Outline: Invoke recipes manipulating a global variable
    Given the Bashfile
      ```bash
      GLOBAL="default-value"

      change-global() {
        GLOBAL='changed-value'
      }

      change-global--subprocess() (
        GLOBAL='changed-value'
      )

      print-global() {
        echo "GLOBAL=${GLOBAL}"
      }

      print-global--subprocess() (
        echo "GLOBAL=${GLOBAL}"
      )
      ```
    When executing bx with "-q <MUTATION RECIPE> <DISPLAY RECIPE>"
    Then bx displays
      """
      GLOBAL=<FINAL GLOBAL VALUE>
      """
    And bx does not error out

    Examples:
      | MUTATION RECIPE           | DISPLAY RECIPE           | FINAL GLOBAL VALUE |
      |                           | print-global             | default-value      |
      | change-global             | print-global             | changed-value      |
      | change-global             | print-global--subprocess | changed-value      |
      | change-global--subprocess | print-global             | default-value      |
      | change-global--subprocess | print-global--subprocess | default-value      |

  Scenario Outline: Invoke a recipe that invokes a recipe that changes a global variable
    Given the Bashfile
      ```bash
      GLOBAL="default-value"

      change-global() {
        GLOBAL='changed-value'
      }

      change-global--subprocess() (
        GLOBAL='changed-value'
      )

      recipe() {
        bx::invoke <MUTATION RECIPE>

        echo "GLOBAL=${GLOBAL}"
      }

      recipe--subprocess() (
        bx::invoke <MUTATION RECIPE>

        echo "GLOBAL=${GLOBAL}"
      )
      ```
    When executing bx with "-q <RECIPE>"
    Then bx displays
      """
      GLOBAL=<FINAL GLOBAL VALUE>
      """
    And bx does not error out

    Examples:
      | RECIPE             | MUTATION RECIPE           | FINAL GLOBAL VALUE |
      | recipe             | change-global             | changed-value      |
      | recipe             | change-global--subprocess | default-value      |
      | recipe--subprocess | change-global             | changed-value      |
      | recipe--subprocess | change-global--subprocess | default-value      |
