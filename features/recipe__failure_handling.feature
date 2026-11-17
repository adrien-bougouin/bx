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
    Then bx outputs to stdout
      """
      Before 'failing-recipe' failure!
      """
    And bx outputs to stderr
      | FORMAT      | CONTENT                                                        |
      | bx-trace-in | failing-recipe                                                 |
      | bx-error    | /Bashfile: line 11: call-missing-function: command not found$/ |
      | bx-error    | Recipe `failing-recipe` exited with status 127!                |
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
      Before 'failing-recipe' failure!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                                                        |
      | bx-trace-in  | recipe-1                                                       |
      | bx-trace-out |                                                                |
      | bx-trace-in  | failing-recipe                                                 |
      | bx-error     | /Bashfile: line 11: call-missing-function: command not found$/ |
      | bx-error     | Recipe `failing-recipe` exited with status 127!                |
    And bx fails

  Scenario: Invoke a recipe that exits with a custom status
    Given the Bashfile
      ```bash
      exiting-recipe() {
        return 42
      }
      ```
    When invoking
      | RECIPE         |
      | exiting-recipe |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT      | CONTENT                                        |
      | bx-trace-in | exiting-recipe                                 |
      | bx-error    | Recipe `exiting-recipe` exited with status 42! |
    And bx fails
