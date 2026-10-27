Feature: Recipe Confirmation -- Nested Invocation

  Background:
    Given the Bashfile
      ```bash
      composite-recipe() {
        bx::invoke "destructive-recipe${@+"$(printf ' "%s"' "$@")"}"
      }

      deep-composite-recipe() {
        bx::invoke destructive-composite-recipe
      }

      destructive-recipe() {
        @confirm

        echo "'destructive-recipe' invoked!"
      }

      destructive-composite-recipe() {
        @confirm

        bx::invoke destructive-recipe

        echo "'destructive-composite-recipe' invoked!"
      }
      ```

  Scenario: Confirm a nested recipe invocation
    When invoking
      | RECIPE           | CONFIRMATION |
      | composite-recipe | y            |
    Then bx outputs to stdout
      """
      'destructive-recipe' invoked!
      """
      And bx outputs to stderr
        | FORMAT       | CONTENT            |
        | bx-trace-in  | composite-recipe   |
        | bx-confirm   | destructive-recipe |
        | bx-trace-in  | destructive-recipe |
        | bx-trace-out |                    |
        | bx-trace-out |                    |
    And bx succeeds

  Scenario Outline: Confirm a nested recipe invocation with arguments
    When invoking
      | RECIPE                              | CONFIRMATION |
      | composite-recipe <RECIPE ARGUMENTS> | y            |
    Then bx outputs to stdout
      """
      'destructive-recipe' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                               |
      | bx-trace-in  | composite-recipe <RECIPE ARGUMENTS>   |
      | bx-confirm   | destructive-recipe <RECIPE ARGUMENTS> |
      | bx-trace-in  | destructive-recipe <RECIPE ARGUMENTS> |
      | bx-trace-out |                                       |
      | bx-trace-out |                                       |
    And bx succeeds

    Examples:
      | RECIPE ARGUMENTS            |
      | arg-1                       |
      | arg-1 arg-2                 |
      | arg\ 1 arg\ 2               |
      | "arg 1" "arg 2"             |
      | --arg=arg\ 1 --arg=arg\ 2   |
      | --arg="arg 1" --arg="arg 2" |

  Scenario: Confirm multiple nested recipe invocations
    When invoking
      | RECIPE                | CONFIRMATION |
      | composite-recipe      | y            |
      | deep-composite-recipe | yy           |
    Then bx outputs to stdout
      """
      'destructive-recipe' invoked!
      'destructive-recipe' invoked!
      'destructive-composite-recipe' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                      |
      | bx-trace-in  | composite-recipe             |
      | bx-confirm   | destructive-recipe           |
      | bx-trace-in  | destructive-recipe           |
      | bx-trace-out |                              |
      | bx-trace-out |                              |
      | bx-trace-in  | deep-composite-recipe        |
      | bx-confirm   | destructive-composite-recipe |
      | bx-trace-in  | destructive-composite-recipe |
      | bx-confirm   | destructive-recipe           |
      | bx-trace-in  | destructive-recipe           |
      | bx-trace-out |                              |
      | bx-trace-out |                              |
      | bx-trace-out |                              |
    And bx succeeds

  Scenario: Reject a nested recipe invocation
    When invoking
      | RECIPE           | CONFIRMATION |
      | composite-recipe | n            |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT      | CONTENT            |
      | bx-trace-in | composite-recipe   |
      | bx-confirm  | destructive-recipe |
      | bx-error    | Aborted!           |
    And bx fails

  Scenario: Confirm then reject nested recipe invocations
    When invoking
      | RECIPE                | CONFIRMATION |
      | composite-recipe      | y            |
      | deep-composite-recipe | n            |
    Then bx outputs to stderr
      | FORMAT       | CONTENT                      |
      | bx-trace-in  | composite-recipe             |
      | bx-confirm   | destructive-recipe           |
      | bx-trace-in  | destructive-recipe           |
      | bx-trace-out |                              |
      | bx-trace-out |                              |
      | bx-trace-in  | deep-composite-recipe        |
      | bx-confirm   | destructive-composite-recipe |
      | bx-error     | Aborted!                     |
    Then bx outputs to stdout
      """
      'destructive-recipe' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                      |
      | bx-trace-in  | composite-recipe             |
      | bx-confirm   | destructive-recipe           |
      | bx-trace-in  | destructive-recipe           |
      | bx-trace-out |                              |
      | bx-trace-out |                              |
      | bx-trace-in  | deep-composite-recipe        |
      | bx-confirm   | destructive-composite-recipe |
      | bx-error     | Aborted!                     |
    And bx fails
