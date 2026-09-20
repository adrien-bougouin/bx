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
    Then bx outputs
      | TYPE       | DATA                          |
      | bx-confirm | recipe-1--critical            |
      | bx-in      | recipe-1--critical            |
      | stdout     | 'recipe-1--critical' invoked! |
      | bx-out     |                               |
    And bx succeeds

    Examples:
      | CONFIRMATION INPUT |
      | y                  |
      | Y                  |

  Scenario Outline: Confirm a recipe invocation with arguments
    When invoking
      | RECIPE                                | CONFIRMATION |
      | recipe-1--critical <RECIPE ARGUMENTS> | y            |
    Then bx outputs
      | TYPE       | DATA                                  |
      | bx-confirm | recipe-1--critical <RECIPE ARGUMENTS> |
      | bx-in      | recipe-1--critical <RECIPE ARGUMENTS> |
      | stdout     | 'recipe-1--critical' invoked!         |
      | bx-out     |                                       |
    And bx succeeds

    Examples:
      | RECIPE ARGUMENTS            |
      | arg-1                       |
      | arg-1 arg-2                 |
      | arg\ 1 arg\ 2               |
      | "arg 1" "arg 2"             |
      | --arg=arg\ 1 --arg=arg\ 2   |
      | --arg="arg 1" --arg="arg 2" |

  Scenario: Confirm multiple recipe invocations
    When invoking
      | RECIPE             | CONFIRMATION |
      | recipe-1--critical | y            |
      | recipe-2--critical | y            |
    Then bx outputs
      | TYPE       | DATA                          |
      | bx-confirm | recipe-1--critical            |
      | bx-in      | recipe-1--critical            |
      | stdout     | 'recipe-1--critical' invoked! |
      | bx-out     |                               |
      | bx-confirm | recipe-2--critical            |
      | bx-in      | recipe-2--critical            |
      | stdout     | 'recipe-2--critical' invoked! |
      | bx-out     |                               |
    And bx succeeds

  Scenario Outline: Reject a recipe invocation
    When invoking
      | RECIPE             | CONFIRMATION      |
      | recipe-1--critical | <REJECTION INPUT> |
    Then bx outputs
      | TYPE       | DATA               |
      | bx-confirm | recipe-1--critical |
      | bx-error   |Aborted!            |
    And bx fails

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
    Then bx outputs
      | TYPE       | DATA                          |
      | bx-confirm | recipe-1--critical            |
      | bx-in      | recipe-1--critical            |
      | stdout     | 'recipe-1--critical' invoked! |
      | bx-out     |                               |
      | bx-confirm | recipe-2--critical            |
      | bx-error   | Aborted!                      |
    And bx fails
