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
        echo "'failing-recipe' before failure!"
        call-missing-function
        echo "'failing-recipe' after failure!"
      }
      ```
  Scenario: Invoke a recipe that fails
    When invoking
      | RECIPE         |
      | failing-recipe |
    Then bx outputs to stdout
      """
      'failing-recipe' before failure!
      """
    And bx traces
      """
      + # failing-recipe {
      """
    And bx errors out with message containing "Bashfile: line 11: call-missing-function: command not found"
    And bx fails

  Scenario: Invoke a mix of recipes that succeed and fail
    When invoking
      | RECIPE         |
      | recipe-1       |
      | failing-recipe |
      | recipe-2       |
    Then bx outputs to stdout
      """
      'recipe-1' invoked!
      'failing-recipe' before failure!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      + # failing-recipe {
      """
    And bx errors out with message containing "Bashfile: line 11: call-missing-function: command not found"
    And bx fails
