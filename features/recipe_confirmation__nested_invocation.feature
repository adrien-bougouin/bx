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
      | recipe | input('y') |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical`? [y/N] |
    And bx displays
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

  Scenario Outline: Confirm a nested recipe invocation with arguments
    When invoking
      | 'recipe <RECIPE ARGUMENTS>' | input('y') |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical <TRACED RECIPE ARGUMENTS>`? [y/N] |
    And bx displays
      """
      'recipe--critical' invoked!
      """
    And bx traces
      """
      + # recipe <TRACED RECIPE ARGUMENTS> {
      ++ # recipe--critical <TRACED RECIPE ARGUMENTS> {
      ++ # }
      + # }
      """
    And bx does not error out

    Examples:
      | RECIPE ARGUMENTS        | TRACED RECIPE ARGUMENTS   |
      | arg-1                   | 'arg-1'                   |
      | arg-1 arg-2             | 'arg-1' 'arg-2'           |
      | arg\ 1 arg\ 2           | 'arg\ 1' 'arg\ 2'         |
      | "arg 1" "arg 2"         | 'arg\ 1' 'arg\ 2'         |
      | --arg=a\ 1 --arg=b\ 2   | '--arg=a\ 1' '--arg=b\ 2' |
      | --arg="a 1" --arg="b 2" | '--arg=a\ 1' '--arg=b\ 2' |

  Scenario: Confirm multiple nested recipe invocations
    When invoking
      | recipe      | input('y') |
      | deep-recipe | input('y') |
      |             | input('y') |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical`? [y/N]      |
      | bx: Invoke recipe `deep-recipe--critical`? [y/N] |
      | bx: Invoke recipe `recipe--critical`? [y/N]      |
    And bx displays
      """
      'recipe--critical' invoked!
      'recipe--critical' invoked!
      'deep-recipe--critical' invoked!
      """
    And bx traces
      """
      + # recipe {
      ++ # recipe--critical {
      ++ # }
      + # }
      + # deep-recipe {
      ++ # deep-recipe--critical {
      +++ # recipe--critical {
      +++ # }
      ++ # }
      + # }
      """
    And bx does not error out

  Scenario: Reject a nested recipe invocation
    When invoking
      | recipe | input('n') |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical`? [y/N] |
    And bx displays nothing
    And bx traces
      """
      + # recipe {
      """
    And bx errors out with message "bx: Aborted!"

  Scenario: Confirm then reject nested recipe invocations
    When invoking
      | recipe      | input('y') |
      | deep-recipe | input('n') |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical`? [y/N]      |
      | bx: Invoke recipe `deep-recipe--critical`? [y/N] |
    And bx displays
      """
      'recipe--critical' invoked!
      """
    And bx traces
      """
      + # recipe {
      ++ # recipe--critical {
      ++ # }
      + # }
      + # deep-recipe {
      """
    And bx errors out with message "bx: Aborted!"
