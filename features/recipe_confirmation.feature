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
      | recipe-1--critical | input('<CONFIRMATION INPUT>') |
    Then bx confirms
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
      | recipe-1--critical <RECIPE ARGUMENTS> | input('y') |
    Then bx confirms
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
      | recipe-1--critical | input('y') |
      | recipe-2--critical | input('y') |
    Then bx confirms
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
      | recipe-1--critical | input('<REJECTION INPUT>') |
    Then bx confirms
      | recipe-1--critical |
    And bx displays nothing
    And bx traces nothing
    And bx errors out with message "bx: Aborted!"

    Examples:
      | REJECTION INPUT |
      |                 |
      | n               |
      | N               |

  Scenario: Confirm then reject recipe invocations
    When invoking
      | recipe-1--critical | input('y') |
      | recipe-2--critical | input('n') |
    Then bx confirms
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
