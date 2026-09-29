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
    Then bx confirms
      | RECIPE           |
      | recipe--critical |
    And bx outputs to stdout
      """
      'recipe--critical' invoked!
      """
    And bx traces
      """
      + # recipe {
      ++ # recipe--critical {
      ++ # }
      + # }
      """
    And bx does not error out
    And bx succeeds

  Scenario Outline: Confirm a nested recipe invocation with arguments
    When invoking
      | RECIPE                    | CONFIRMATION |
      | recipe <RECIPE ARGUMENTS> | y            |
    Then bx outputs to stdout
      """
      'recipe--critical' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                             |
      | bx-trace-in  | recipe <RECIPE ARGUMENTS>           |
      | bx-confirm   | recipe--critical <RECIPE ARGUMENTS> |
      | bx-trace-in  | recipe--critical <RECIPE ARGUMENTS> |
      | bx-trace-out |                                     |
      | bx-trace-out |                                     |
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
    Then bx outputs to stdout
      """
      'recipe--critical' invoked!
      'recipe--critical' invoked!
      'deep-recipe--critical' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT               |
      | bx-trace-in  | recipe                |
      | bx-confirm   | recipe--critical      |
      | bx-trace-in  | recipe--critical      |
      | bx-trace-out |                       |
      | bx-trace-out |                       |
      | bx-trace-in  | deep-recipe           |
      | bx-confirm   | deep-recipe--critical |
      | bx-trace-in  | deep-recipe--critical |
      | bx-confirm   | recipe--critical      |
      | bx-trace-in  | recipe--critical      |
      | bx-trace-out |                       |
      | bx-trace-out |                       |
      | bx-trace-out |                       |
    And bx succeeds

  Scenario: Reject a nested recipe invocation
    When invoking
      | RECIPE | CONFIRMATION |
      | recipe | n            |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT       | CONTENT          |
      | bx-trace-in  | recipe           |
      | bx-confirm   | recipe--critical |
      | bx-error     | Aborted!         |
    And bx fails

  Scenario: Confirm then reject nested recipe invocations
    When invoking
      | RECIPE      | CONFIRMATION |
      | recipe      | y            |
      | deep-recipe | n            |
    Then bx outputs to stdout
      """
      'recipe--critical' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT               |
      | bx-trace-in  | recipe                |
      | bx-confirm   | recipe--critical      |
      | bx-trace-in  | recipe--critical      |
      | bx-trace-out |                       |
      | bx-trace-out |                       |
      | bx-trace-in  | deep-recipe           |
      | bx-confirm   | deep-recipe--critical |
      | bx-error     | Aborted!              |
    And bx fails
