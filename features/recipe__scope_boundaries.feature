Feature: Recipe--Scope Boundaries

  Scenario Outline: Invoke recipes manipulating a global variable
    Given the Bakefile
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
    When executing Bake with arguments "-q <MUTATION RECIPE> <DISPLAY RECIPE>"
    Then Bake displays
      """
      GLOBAL=<FINAL GLOBAL VALUE>
      """
    And Bake does not error out

    Examples:
      | MUTATION RECIPE           | DISPLAY RECIPE           | FINAL GLOBAL VALUE |
      |                           | print-global             | default-value      |
      | change-global             | print-global             | changed-value      |
      | change-global             | print-global--subprocess | changed-value      |
      | change-global--subprocess | print-global             | default-value      |
      | change-global--subprocess | print-global--subprocess | default-value      |
