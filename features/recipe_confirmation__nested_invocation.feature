@skip
Feature: Recipe Confirmation -- Nested Invocation

  Background:
    Given the Bashfile
      ```bash
      recipe() {
        bx::invoke recipe--critical
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
    When executing bx with "recipe" and inputting
      | yes |
    Then bx confirms
      | bx: Invoke recipe 'recipe--critical'? [y/N] |
    And bx displays
      """
      'recipe--critical' code executed!
      """
    And bx does not error out

  Scenario: Confirm multiple nested recipe invocations
    When executing bx with "recipe deep-recipe" and inputting
      | yes |
      | yes |
      | yes |
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
    And bx does not error out

  Scenario: Reject a nested recipe invocation
    When executing bx with "recipe" and inputting
      | no |
    Then bx confirms
      | bx: Invoke recipe 'recipe--critical'? [y/N] |
    And bx displays nothing
    And bx errors out with message "bx: Abort!"

  Scenario: Confirm then reject nested recipe invocations
    When executing bx with "recipe deep-recipe" and inputting
      | yes |
      | no  |
    Then bx confirms
      | bx: Invoke recipe 'recipe--critical'? [y/N] |
      | bx: Invoke recipe 'deep-recipe--critical'? [y/N] |
    And bx displays
      """
      'recipe--critical' code executed!
      """
    And bx errors out with message "bx: Abort!"
