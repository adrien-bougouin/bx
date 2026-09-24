Feature: Recipe Auto-Confirmation

  Background:
    Given the Bashfile
      ```bash
      deep-recipe() {
        bx::invoke recipe-1--critical recipe-2--critical
        bx::invoke recipe-3--critical
      }

      recipe-1--critical() {
        @confirm

        echo "'recipe-1--critical' invoked!"
      }

      recipe-2--critical() {
        @confirm

        echo "'recipe-2--critical' invoked!"
      }

      recipe-3--critical() {
        @confirm

        echo "'recipe-3--critical' invoked!"
      }
      ```

  Scenario Outline: Auto-confirm a recipe invocation
    When setting
      | OPTION                  |
      | <CONFIRMATION ARGUMENT> |
    And invoking
      | RECIPE             |
      | recipe-1--critical |
    Then bx outputs
      | FORMAT | DATA                          |
      | bx-in  | recipe-1--critical            |
      |        | 'recipe-1--critical' invoked! |
      | bx-out |                               |
    And bx succeeds

    Examples:
      | CONFIRMATION ARGUMENT |
      | -y                    |
      | --yes                 |

  Scenario: Auto-confirm multiple recipe invocations
    When setting
      | OPTION |
      | --yes  |
    And invoking
      | RECIPE             |
      | recipe-1--critical |
      | recipe-2--critical |
    Then bx outputs
      | FORMAT | DATA                          |
      | bx-in  | recipe-1--critical            |
      |        | 'recipe-1--critical' invoked! |
      | bx-out |                               |
      | bx-in  | recipe-2--critical            |
      |        | 'recipe-2--critical' invoked! |
      | bx-out |                               |
    And bx succeeds

  Scenario: Auto-confirm nested recipe invocations
    When setting
      | OPTION |
      | --yes  |
    And invoking
      | RECIPE      |
      | deep-recipe |
    Then bx outputs
      | FORMAT | DATA                          |
      | bx-in  | deep-recipe                   |
      | bx-in  | recipe-1--critical            |
      |        | 'recipe-1--critical' invoked! |
      | bx-out |                               |
      | bx-in  | recipe-2--critical            |
      |        | 'recipe-2--critical' invoked! |
      | bx-out |                               |
      | bx-in  | recipe-3--critical            |
      |        | 'recipe-3--critical' invoked! |
      | bx-out |                               |
      | bx-out |                               |
    And bx succeeds
