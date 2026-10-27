Feature: Recipe Auto-Confirmation

  Background:
    Given the Bashfile
      ```bash
      composite-recipe() {
        bx::invoke destructive-recipe-1 destructive-recipe-2
        bx::invoke destructive-recipe-3
      }

      destructive-recipe-1() {
        @confirm

        echo "'destructive-recipe-1' invoked!"
      }

      destructive-recipe-2() {
        @confirm

        echo "'destructive-recipe-2' invoked!"
      }

      destructive-recipe-3() {
        @confirm

        echo "'destructive-recipe-3' invoked!"
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
      | RECIPE               |
      | destructive-recipe-1 |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
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
      | RECIPE               |
      | destructive-recipe-1 |
      | destructive-recipe-2 |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      'destructive-recipe-2' invoked!
      """
    And bx succeeds

  Scenario: Auto-confirm nested recipe invocations
    When setting
      | OPTION |
      | --yes  |
    And invoking
      | RECIPE           |
      | composite-recipe |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      'destructive-recipe-2' invoked!
      'destructive-recipe-3' invoked!
      """
    And bx succeeds

  @regression
  Scenario: Invoking, without auto-confirm, a tricky recipe with -y in the name
    When invoking
      | RECIPE                               | CONFIRMATION |
      | tricky-recipe-y destructive-recipe-1 | n            |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT      | CONTENT                              |
      | bx-trace-in | tricky-recipe-y destructive-recipe-1 |
      | bx-confirm  | destructive-recipe-1                 |
      | bx-error    | Aborted!                             |
    And bx fails
