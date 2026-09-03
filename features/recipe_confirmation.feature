Feature: Recipe Confirmation

  Background:
    Given the Bashfile
      ```bash
      recipe-1--critical() {
        @confirm

        echo "'recipe-1--critical' invoked!"
      }

      recipe-2--critical() {
        @confirm

        echo "'recipe-2--critical' invoked!"
      }
      ```

  Scenario Outline: Confirm a recipe invocation
    When executing bx with "recipe-1--critical" and confirmation sequence
      | <CONFIRMATION INPUT> |
    Then bx confirms
      | bx: Invoke recipe `recipe-1--critical`? [y/N] |
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
      | CONFIRMATION INPUT |
      | y                  |
      | Y                  |

  Scenario: Confirm a recipe invocation with arguments
    When executing bx with "'recipe-1--critical arg-1 arg-2'" and confirmation sequence
      | y |
    Then bx confirms
      | bx: Invoke recipe `recipe-1--critical arg-1 arg-2`? [y/N] |
    And bx displays
      """
      'recipe-1--critical' invoked!
      """
    And bx traces
      """
      + # recipe-1--critical arg-1 arg-2 {
      + # }
      """
    And bx does not error out

  Scenario: Confirm multiple recipe invocations
    When executing bx with "recipe-1--critical recipe-2--critical" and confirmation sequence
      | y |
      | y |
    Then bx confirms
      | bx: Invoke recipe `recipe-1--critical`? [y/N] |
      | bx: Invoke recipe `recipe-2--critical`? [y/N] |
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

  Scenario Outline: Reject a recipe invocation
    When executing bx with "recipe-1--critical" and confirmation sequence
      | <REJECTION INPUT> |
    Then bx confirms
      | bx: Invoke recipe `recipe-1--critical`? [y/N] |
    And bx displays nothing
    And bx traces nothing
    And bx errors out with message "bx: Aborted!"

    Examples:
      | REJECTION INPUT |
      |                 |
      | n               |
      | N               |

  Scenario: Confirm then reject recipe invocations
    When executing bx with "recipe-1--critical recipe-2--critical" and confirmation sequence
      | y |
      | n |
    Then bx confirms
      | bx: Invoke recipe `recipe-1--critical`? [y/N] |
      | bx: Invoke recipe `recipe-2--critical`? [y/N] |
    And bx displays
      """
      'recipe-1--critical' invoked!
      """
    And bx traces
      """
      + # recipe-1--critical {
      + # }
      """
    And bx errors out with message "bx: Aborted!"
