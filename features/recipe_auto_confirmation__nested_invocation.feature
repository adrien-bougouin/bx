Feature: Recipe Auto-Confirmation -- Nested Invocation

  Background:
    Given the Bashfile
      ```bash
      safe-composite-recipe() {
        bx::invoke --yes destructive-recipe-1 destructive-recipe-2
        bx::invoke -y destructive-recipe-3
      }

      safe-deep-composite-recipe() {
        bx::invoke --yes destructive-composite-recipe
      }

      destructive-composite-recipe() {
        @confirm

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
      ```

  Scenario Outline: Invoke a recipe that auto-confirms all nested recipe invocations
    When invoking
      | RECIPE   |
      | <RECIPE> |
    Then bx confirms nothing
    And bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      'destructive-recipe-2' invoked!
      'destructive-recipe-3' invoked!
      """
    And bx succeeds

    Examples:
      | RECIPE                     |
      | safe-composite-recipe      |
      | safe-deep-composite-recipe |

  Scenario: Invoking multiple recipes with only one that auto-confirms nested recipe invocations
    When invoking
      | RECIPE                       | CONFIRMATION |
      | safe-composite-recipe        |              |
      | destructive-composite-recipe | yyyy         |
    Then bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      'destructive-recipe-2' invoked!
      'destructive-recipe-3' invoked!
      'destructive-recipe-1' invoked!
      'destructive-recipe-2' invoked!
      'destructive-recipe-3' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                      |
      | bx-trace-in  | safe-composite-recipe        |
      | bx-trace-in  | destructive-recipe-1         |
      | bx-trace-out |                              |
      | bx-trace-in  | destructive-recipe-2         |
      | bx-trace-out |                              |
      | bx-trace-in  | destructive-recipe-3         |
      | bx-trace-out |                              |
      | bx-trace-out |                              |
      | bx-confirm   | destructive-composite-recipe |
      | bx-trace-in  | destructive-composite-recipe |
      | bx-confirm   | destructive-recipe-1         |
      | bx-trace-in  | destructive-recipe-1         |
      | bx-trace-out |                              |
      | bx-confirm   | destructive-recipe-2         |
      | bx-trace-in  | destructive-recipe-2         |
      | bx-trace-out |                              |
      | bx-confirm   | destructive-recipe-3         |
      | bx-trace-in  | destructive-recipe-3         |
      | bx-trace-out |                              |
      | bx-trace-out |                              |
    And bx succeeds
