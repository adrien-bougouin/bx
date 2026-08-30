@todo
Feature: Recipe Confirmation

  Background:
    Given the Bashfile
      ```bash
      recipe-1--critical() {
        @confirm

        echo "'recipe-1--critical' code executed!"
      }

      recipe-2--critical() {
        @confirm

        echo "'recipe-2--critical' code executed!"
      }
      ```

  Scenario Outline: Confirm a recipe invocation
    When executing bx with "recipe-1--critical" and inputting
      | <CONFIRMATION INPUT> |
    Then bx confirms
      | bx: Invoke recipe 'recipe-1--critical'? [y/N] |
    And bx displays
      """
      'recipe-1--critical' code executed!
      """
    And bx does not error out

    Examples:
      | CONFIRMATION INPUT |
      | y                  |
      | Y                  |
      | yes                |
      | Yes                |
      | YES                |

  Scenario: Confirm multiple recipe invocations
    When executing bx with "recipe-1--critical recipe-2--critical" and inputting
      | yes |
      | yes |
    Then bx confirms
      | bx: Invoke recipe 'recipe-1--critical'? [y/N] |
      | bx: Invoke recipe 'recipe-2--critical'? [y/N] |
    And bx displays
      """
      'recipe-1--critical' code executed!
      'recipe-2--critical' code executed!
      """
    And bx does not error out

  Scenario Outline: Reject a recipe invocation
    When executing bx with "recipe-1--critical" and inputting
      | <REJECTION INPUT> |
    Then bx confirms
      | bx: Invoke recipe 'recipe-1--critical'? [y/N] |
    And bx displays nothing
    And bx traces nothing
    And bx errors out with message "bx: Aborted!"

    Examples:
      | REJECTION INPUT |
      |                 |
      | n               |
      | N               |
      | no              |
      | No              |
      | NO              |

  Scenario: Confirm then reject recipe invocations
    When executing bx with "recipe-1--critical recipe-2--critical" and inputting
      | yes |
      | no  |
    Then bx confirms
      | bx: Invoke recipe 'recipe-1--critical'? [y/N] |
      | bx: Invoke recipe 'recipe-2--critical'? [y/N] |
    And bx displays
      """
      'recipe-1--critical' code executed!
      """
    And bx traces
      """
      + # recipe-1--critical {
      + # }
      """
    And bx errors out with message "bx: Aborted!"
