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
    When executing bx with "recipe" and confirmation sequence
      | y |
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
    When executing bx with '\'recipe <RECIPE ARGUMENTS>\'' and confirmation sequence
      | y |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical <FORWARDED ARGUMENTS>`? [y/N] |
    And bx displays
      """
      'recipe--critical' invoked!
      """
    And bx traces
      """
      + # recipe <RECIPE ARGUMENTS> {
      ++ # recipe--critical <FORWARDED ARGUMENTS> {
      ++ # }
      + # }
      """
    And bx does not error out

    Examples:
      | RECIPE ARGUMENTS                 | FORWARDED ARGUMENTS         |
      | arg-1                            | "arg-1"                     |
      | arg-1 arg-2                      | "arg-1" "arg-2"             |
      | arg\ 1 arg\ 2                    | "arg 1" "arg 2"             |
      | "arg 1" "arg 2"                  | "arg 1" "arg 2"             |
      | --arg=arg\ 1 --arg=arg\ 2        | "--arg=arg 1" "--arg=arg 2" |
      | --arg="arg 1" --arg="arg 2"      | "--arg=arg 1" "--arg=arg 2" |

  Scenario: Confirm multiple nested recipe invocations
    When executing bx with "recipe deep-recipe" and confirmation sequence
      | y |
      | y |
      | y |
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
    When executing bx with "recipe" and confirmation sequence
      | n |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical`? [y/N] |
    And bx displays nothing
    And bx traces
      """
      + # recipe {
      """
    And bx errors out with message "bx: Aborted!"

  Scenario: Confirm then reject nested recipe invocations
    When executing bx with "recipe deep-recipe" and confirmation sequence
      | y |
      | n |
    Then bx confirms
      | bx: Invoke recipe `recipe--critical`? [y/N] |
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
