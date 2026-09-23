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
    When setting options
      | -q |
    And invoking
      | RECIPE   |
      | <RECIPE> |
    Then bx confirms nothing
    And bx outputs
      | TYPE   | DATA                          |
      | stdout | 'recipe-1--critical' invoked! |
      | stdout | 'recipe-2--critical' invoked! |
      | stdout | 'recipe-3--critical' invoked! |
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
    Then bx outputs
      | TYPE       | DATA                          |
      | bx-in      | recipe--safe                  |
      | bx-in      | recipe-1--critical            |
      | stdout     | 'recipe-1--critical' invoked! |
      | bx-out     |                               |
      | bx-in      | recipe-2--critical            |
      | stdout     | 'recipe-2--critical' invoked! |
      | bx-out     |                               |
      | bx-in      | recipe-3--critical            |
      | stdout     | 'recipe-3--critical' invoked! |
      | bx-out     |                               |
      | bx-out     |                               |
      | bx-confirm | deep-recipe--critical         |
      | bx-in      | deep-recipe--critical         |
      | bx-confirm | recipe-1--critical            |
      | bx-in      | recipe-1--critical            |
      | stdout     | 'recipe-1--critical' invoked! |
      | bx-out     |                               |
      | bx-confirm | recipe-2--critical            |
      | bx-in      | recipe-2--critical            |
      | stdout     | 'recipe-2--critical' invoked! |
      | bx-out     |                               |
      | bx-confirm | recipe-3--critical            |
      | bx-in      | recipe-3--critical            |
      | stdout     | 'recipe-3--critical' invoked! |
      | bx-out     |                               |
      | bx-out     |                               |
    And bx succeeds
