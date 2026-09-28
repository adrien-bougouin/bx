Feature: Recipe Auto-Confirmation -- Nested Invocation

  Background:
    Given the Bashfile
      ```bash
      recipe--safe() {
        bx::invoke --yes recipe-1--critical recipe-2--critical
        bx::invoke -y recipe-3--critical
      }

      deep-recipe--safe() {
        bx::invoke --yes deep-recipe--critical
      }

      deep-recipe--critical() {
        @confirm

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
      ```

  Scenario Outline: Invoke a recipe that auto-confirms all nested recipe invocations
    When invoking
      | RECIPE   |
      | <RECIPE> |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      """
    And bx succeeds

    Examples:
      | RECIPE            |
      | recipe--safe      |
      | deep-recipe--safe |

  Scenario: Invoking multiple recipes with only one that auto-confirms nested recipe invocations
    When invoking
      | RECIPE                | CONFIRMATION |
      | recipe--safe          |              |
      | deep-recipe--critical | yyyy         |
    Then bx outputs to stdout
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT               |
      | bx-trace-in  | recipe--safe          |
      | bx-trace-in  | recipe-1--critical    |
      | bx-trace-out |                       |
      | bx-trace-in  | recipe-2--critical    |
      | bx-trace-out |                       |
      | bx-trace-in  | recipe-3--critical    |
      | bx-trace-out |                       |
      | bx-trace-out |                       |
      | bx-confirm   | deep-recipe--critical |
      | bx-trace-in  | deep-recipe--critical |
      | bx-confirm   | recipe-1--critical    |
      | bx-trace-in  | recipe-1--critical    |
      | bx-trace-out |                       |
      | bx-confirm   | recipe-2--critical    |
      | bx-trace-in  | recipe-2--critical    |
      | bx-trace-out |                       |
      | bx-confirm   | recipe-3--critical    |
      | bx-trace-in  | recipe-3--critical    |
      | bx-trace-out |                       |
      | bx-trace-out |                       |
    And bx succeeds
