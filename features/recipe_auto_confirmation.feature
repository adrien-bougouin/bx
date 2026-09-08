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
      ```

  Scenario Outline: Auto-confirm a recipe invocation
    When executing bx with "<CONFIRMATION ARGUMENT> recipe-1--critical"
    Then bx confirms nothing
    And bx displays
      """
      'recipe-1--critical' invoked!
      """
    And bx traces
      """
      + # recipe-1--critical {
      + # }
      """
    And bx does not error out

    Examples:
      | CONFIRMATION ARGUMENT |
      | -y                    |
      | --yes                 |

  Scenario: Auto-confirm multiple recipe invocations
    When executing bx with "-y recipe-1--critical recipe-2--critical"
    Then bx confirms nothing
    And bx displays
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      """
    And bx traces
      """
      + # recipe-1--critical {
      + # }
      + # recipe-2--critical {
      + # }
      """
    And bx does not error out

  Scenario: Auto-confirm nested recipe invocations
    When executing bx with "-y deep-recipe"
    Then bx confirms nothing
    And bx displays
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      """
    And bx traces
      """
      + # deep-recipe {
      ++ # recipe-1--critical {
      ++ # }
      ++ # recipe-2--critical {
      ++ # }
      ++ # recipe-3--critical {
      ++ # }
      + # }
      """
    And bx does not error out
