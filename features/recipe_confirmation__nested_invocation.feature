Feature: Recipe Confirmation -- Nested Invocation

  Background:
    Given the Bashfile
      ```bash
      recipe() {
        if [[ $# -gt 0 ]]; then
          bx::invoke "recipe--critical $*"
        else
          bx::invoke recipe--critical
        fi
      }

      recipe--critical() {
        @confirm

        echo "'recipe--critical' code executed!"
      }

      deep-recipe() {
        bx::invoke deep-recipe--critical
      }

      deep-recipe--critical() {
        @confirm

        bx::invoke recipe--critical

        echo "'deep-recipe--critical' code executed!"
      }
      ```

  Scenario: Confirm a nested recipe invocation
    When executing bx with "recipe" and confirmation sequence
      | y |
    Then bx confirms
      | bx: Invoke recipe 'recipe--critical'? [y/N] |
    And bx displays
      """
      'recipe--critical' code executed!
      """
    And bx traces
      """
      + # recipe {
      ++ # recipe--critical {
      ++ # }
      + # }
      """
    And bx does not error out

  Scenario: Confirm a nested recipe invocation with arguments
    When executing bx with "'recipe arg-1 arg-2'" and confirmation sequence
      | y |
    Then bx confirms
      | bx: Invoke recipe 'recipe--critical arg-1 arg-2'? [y/N] |
    And bx displays
      """
      'recipe--critical' code executed!
      """
    And bx traces
      """
      + # recipe arg-1 arg-2 {
      ++ # recipe--critical arg-1 arg-2 {
      ++ # }
      + # }
      """
    And bx does not error out

  Scenario: Confirm multiple nested recipe invocations
    When executing bx with "recipe deep-recipe" and confirmation sequence
      | y |
      | y |
      | y |
    Then bx confirms
      | bx: Invoke recipe 'recipe--critical'? [y/N]      |
      | bx: Invoke recipe 'deep-recipe--critical'? [y/N] |
      | bx: Invoke recipe 'recipe--critical'? [y/N]      |
    And bx displays
      """
      'recipe--critical' code executed!
      'recipe--critical' code executed!
      'deep-recipe--critical' code executed!
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
      | bx: Invoke recipe 'recipe--critical'? [y/N] |
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
      | bx: Invoke recipe 'recipe--critical'? [y/N] |
      | bx: Invoke recipe 'deep-recipe--critical'? [y/N] |
    And bx displays
      """
      'recipe--critical' code executed!
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
