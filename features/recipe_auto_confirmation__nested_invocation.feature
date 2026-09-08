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
    When executing bx with "<RECIPE>"
    Then bx confirms nothing
    And bx displays
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      """
    And bx does not error out

    Examples:
      | RECIPE            |
      | recipe--safe      |
      | deep-recipe--safe |

  Scenario: Invoking multiple recipes with only one that auto-confirms nested recipe invocations
    When executing bx with "recipe--safe deep-recipe--critical" and confirmation sequence
      | y |
      | y |
      | y |
      | y |
    Then bx confirms
      | bx: Invoke recipe `deep-recipe--critical`? [y/N] |
      | bx: Invoke recipe `recipe-1--critical`? [y/N] |
      | bx: Invoke recipe `recipe-2--critical`? [y/N] |
      | bx: Invoke recipe `recipe-3--critical`? [y/N] |
    And bx displays
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      """
    And bx traces
      """
      + # recipe--safe {
      ++ # recipe-1--critical {
      ++ # }
      ++ # recipe-2--critical {
      ++ # }
      ++ # recipe-3--critical {
      ++ # }
      + # }
      + # deep-recipe--critical {
      ++ # recipe-1--critical {
      ++ # }
      ++ # recipe-2--critical {
      ++ # }
      ++ # recipe-3--critical {
      ++ # }
      + # }
      """
    And bx does not error out
