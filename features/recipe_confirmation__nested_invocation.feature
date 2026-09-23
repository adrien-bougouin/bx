Feature: Recipe Confirmation -- Nested Invocation

  Background:
    Given the Bashfile
      ```bash
      recipe() {
        bx::invoke "recipe--critical${@+"$(printf ' "%s"' "$@")"}"
      }

      recipe--critical() {
        @confirm

        echo "'recipe--critical' invoked!"
      }

      deep-recipe() {
        bx::invoke deep-recipe--critical
      }

      deep-recipe--critical() {
        @confirm

        bx::invoke recipe--critical

        echo "'deep-recipe--critical' invoked!"
      }
      ```

  Scenario: Confirm a nested recipe invocation
    When invoking
      | RECIPE | CONFIRMATION |
      | recipe | y            |
    Then bx outputs
      | TYPE       | DATA                        |
      | bx-in      | recipe                      |
      | bx-confirm | recipe--critical            |
      | bx-in      | recipe--critical            |
      |            | 'recipe--critical' invoked! |
      | bx-out     |                             |
      | bx-out     |                             |
    And bx succeeds

  Scenario Outline: Confirm a nested recipe invocation with arguments
    When invoking
      | RECIPE                    | CONFIRMATION |
      | recipe <RECIPE ARGUMENTS> | y            |
    Then bx outputs
      | TYPE       | DATA                                |
      | bx-in      | recipe <RECIPE ARGUMENTS>           |
      | bx-confirm | recipe--critical <RECIPE ARGUMENTS> |
      | bx-in      | recipe--critical <RECIPE ARGUMENTS> |
      |            | 'recipe--critical' invoked!         |
      | bx-out     |                                     |
      | bx-out     |                                     |
    And bx succeeds

    Examples:
      | RECIPE ARGUMENTS        |
      | arg-1                   |
      | arg-1 arg-2             |
      | arg\ 1 arg\ 2           |
      | "arg 1" "arg 2"         |
      | --arg=a\ 1 --arg=b\ 2   |
      | --arg="a 1" --arg="b 2" |

  Scenario: Confirm multiple nested recipe invocations
    When invoking
      | RECIPE      | CONFIRMATION |
      | recipe      | y            |
      | deep-recipe | yy           |
    Then bx outputs
      | TYPE       | DATA                             |
      | bx-in      | recipe                           |
      | bx-confirm | recipe--critical                 |
      | bx-in      | recipe--critical                 |
      |            | 'recipe--critical' invoked!      |
      | bx-out     |                                  |
      | bx-out     |                                  |
      | bx-in      | deep-recipe                      |
      | bx-confirm | deep-recipe--critical            |
      | bx-in      | deep-recipe--critical            |
      | bx-confirm | recipe--critical                 |
      | bx-in      | recipe--critical                 |
      |            | 'recipe--critical' invoked!      |
      | bx-out     |                                  |
      |            | 'deep-recipe--critical' invoked! |
      | bx-out     |                                  |
      | bx-out     |                                  |
    And bx succeeds

  Scenario: Reject a nested recipe invocation
    When invoking
      | RECIPE | CONFIRMATION |
      | recipe | n            |
    Then bx outputs
      | TYPE       | DATA             |
      | bx-in      | recipe           |
      | bx-confirm | recipe--critical |
      | bx-error   | Aborted!         |
    And bx fails

  Scenario: Confirm then reject nested recipe invocations
    When invoking
      | RECIPE      | CONFIRMATION |
      | recipe      | y            |
      | deep-recipe | n            |
    Then bx outputs
      | TYPE       | DATA                        |
      | bx-in      | recipe                      |
      | bx-confirm | recipe--critical            |
      | bx-in      | recipe--critical            |
      |            | 'recipe--critical' invoked! |
      | bx-out     |                             |
      | bx-out     |                             |
      | bx-in      | deep-recipe                 |
      | bx-confirm | deep-recipe--critical       |
      | bx-error   | Aborted!                    |
    And bx fails
