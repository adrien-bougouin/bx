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
    When invoking
      | RECIPE             | CONFIRMATION         |
      | recipe-1--critical | <CONFIRMATION INPUT> |
    Then bx confirms
      | RECIPE             |
      | recipe-1--critical |
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

  Scenario Outline: Confirm a recipe invocation with arguments
    When invoking
      | RECIPE                                | CONFIRMATION |
      | recipe-1--critical <RECIPE ARGUMENTS> | y            |
    Then bx confirms
      | RECIPE                                |
      | recipe-1--critical <RECIPE ARGUMENTS> |
    And bx displays
      """
      'recipe-1--critical' invoked!
      """
    And bx traces
      """
      + # recipe-1--critical <TRACED RECIPE ARGUMENTS> {
      + # }
      """
    And bx does not error out

    Examples:
      | RECIPE ARGUMENTS            | TRACED RECIPE ARGUMENTS       |
      | arg-1                       | 'arg-1'                       |
      | arg-1 arg-2                 | 'arg-1' 'arg-2'               |
      | arg\ 1 arg\ 2               | 'arg\ 1' 'arg\ 2'             |
      | "arg 1" "arg 2"             | 'arg\ 1' 'arg\ 2'             |
      | --arg=arg\ 1 --arg=arg\ 2   | '--arg=arg\ 1' '--arg=arg\ 2' |
      | --arg="arg 1" --arg="arg 2" | '--arg=arg\ 1' '--arg=arg\ 2' |

  Scenario: Confirm multiple recipe invocations
    When invoking
      | RECIPE             | CONFIRMATION |
      | recipe-1--critical | y            |
      | recipe-2--critical | y            |
    Then bx confirms
      | RECIPE             |
      | recipe-1--critical |
      | recipe-2--critical |
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
    When invoking
      | RECIPE             | CONFIRMATION      |
      | recipe-1--critical | <REJECTION INPUT> |
    Then bx confirms
      | RECIPE             |
      | recipe-1--critical |
    And bx displays nothing
    And bx traces nothing
    And bx errors out with message "bx: Aborted!"

    Examples:
      | REJECTION INPUT |
      | ?               |
      | n               |
      | N               |

  Scenario: Confirm then reject recipe invocations
    When invoking
      | RECIPE             | CONFIRMATION |
      | recipe-1--critical | y            |
      | recipe-2--critical | n            |
    Then bx confirms
      | RECIPE             |
      | recipe-1--critical |
      | recipe-2--critical |
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
