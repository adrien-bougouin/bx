Feature: Recipe Auto-Confirmation

  Background:
    Given the Bashfile
      ```bash
      recipe--deep() {
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
    Then bx does not error out
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
    When executing bx with "-y recipe--deep"
    Then bx confirms nothing
    And bx displays
      """
      'recipe-1--critical' invoked!
      'recipe-2--critical' invoked!
      'recipe-3--critical' invoked!
      """
    And bx traces
      """
      + # recipe--deep {
      ++ # recipe-1--critical {
      ++ # }
      ++ # recipe-2--critical {
      ++ # }
      ++ # recipe-3--critical {
      ++ # }
      + # }
      """
    And bx does not error out
