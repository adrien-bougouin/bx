Feature: Recipe Auto-Confirmation

  Background:
    Given the Bashfile
      ```bash
      deep-recipe() {
        bx::invoke recipe-1--critical recipe-2--critical
        bx::invoke recipe-3--critical
      }

      recipe-1--critical() {
        @confirm

        echo "'recipe-1--critical' invoked!"
      }

      recipe-2--critical() {
        @confirm

        echo "'recipe-2--critical' invoked!"
      }

      recipe-3--critical() {
        @confirm

        echo "'recipe-3--critical' invoked!"
      }

      # Regression: "-y" suffix should not be interpretted as yes
      tricky-recipe-y() {
        bx::invoke "$1"
      }
      ```

  Scenario Outline: Auto-confirm a recipe invocation
    When setting
      | OPTION                  |
      | <CONFIRMATION ARGUMENT> |
    And invoking
      | RECIPE             |
      | recipe-1--critical |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'recipe-1--critical' invoked!
      """
    And bx succeeds

    Examples:
      | CONFIRMATION ARGUMENT |
      | -y                    |
      | --yes                 |

  Scenario: Auto-confirm multiple recipe invocations
    When setting
      | OPTION |
      | --yes  |
    And invoking
      | RECIPE             |
      | recipe-1--critical |
      | recipe-2--critical |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      """
    And bx succeeds

  Scenario: Auto-confirm nested recipe invocations
    When setting
      | OPTION |
      | --yes  |
    And invoking
      | RECIPE      |
      | deep-recipe |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      """
    And bx succeeds

  @regression
  Scenario: Invoking, without auto-confirm, a tricky recipe with -y in the name
    When invoking
      | RECIPE                             | CONFIRMATION |
      | tricky-recipe-y recipe-1--critical | n            |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT      | CONTENT                            |
      | bx-trace-in | tricky-recipe-y recipe-1--critical |
      | bx-confirm  | recipe-1--critical                 |
      | bx-error    | Aborted!                           |
    And bx fails
