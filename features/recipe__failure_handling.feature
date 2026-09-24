Feature: Recipe -- Failure Handling

  Background:
    Given the Bashfile
      ```bash
      recipe-1() {
        echo "'recipe-1' invoked!"
      }

      recipe-2() {
        echo "'recipe-2' invoked!"
      }

      failing-recipe() {
        echo "Before 'failing-recipe' failure!"
        call-missing-function
        echo "After 'failing-recipe' failure!"
      }
      ```

  Scenario: Invoke a recipe that fails
    When invoking
      | RECIPE         |
      | failing-recipe |
    Then bx outputs
      | FORMAT | DATA                                                        |
      | bx-in  | failing-recipe                                              |
      |        | Before 'failing-recipe' failure!                            |
      |        | /Bashfile: [^:]+: call-missing-function: command not found/ |
    And bx fails

  Scenario: Invoke a mix of recipes that succeed and fail
    When invoking
      | RECIPE         |
      | recipe-1       |
      | failing-recipe |
      | recipe-2       |
    Then bx outputs
      | FORMAT | DATA                                                        |
      | bx-in  | recipe-1                                                    |
      |        | 'recipe-1' invoked!                                         |
      | bx-out |                                                             |
      | bx-in  | failing-recipe                                              |
      |        | Before 'failing-recipe' failure!                            |
      |        | /Bashfile: [^:]+: call-missing-function: command not found/ |
    And bx fails
