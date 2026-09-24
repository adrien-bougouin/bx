Feature: Recipe

  A recipe is a set of instructions declared in a Bashfile as a Bash function. A
  recipe is invoked by name; invoking a recipe executes its body. Private
  functions, prefixed by "_" by convention, are not treated as recipes.

  Background:
    Given the Bashfile
      ```bash
      recipe-1() {
        echo "'recipe-1' invoked!"
      }

      recipe-2() {
        echo "'recipe-2' invoked!"
      }

      _not-a-recipe() {
        echo "'_not-a-recipe' invoked!"
      }
      ```

  Scenario: Invoke a recipe
    When invoking
      | RECIPE   |
      | recipe-1 |
    Then bx displays
      """
      'recipe-1' invoked!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      """
    And bx does not error out
    And bx succeeds

  Scenario: Invoke a recipe multiple times
    When invoking
      | RECIPE   |
      | recipe-1 |
      | recipe-1 |
    Then bx displays
      """
      'recipe-1' invoked!
      'recipe-1' invoked!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      + # recipe-1 {
      + # }
      """
    And bx does not error out
    And bx succeeds

  Scenario: Invoke a missing recipe
    When invoking
      | RECIPE  |
      | missing |
    Then bx displays nothing
    And bx errors out with message "bx: No recipe `missing`!"
    And bx fails

  Scenario: Invoke a private function instead of a recipe
    When invoking
      | RECIPE        |
      | _not-a-recipe |
    Then bx displays nothing
    And bx errors out with message "bx: `_not-a-recipe` is a private function, not a recipe!"
    And bx fails

  Scenario: Invoke multiple recipes
    When invoking
      | RECIPE   |
      | recipe-1 |
      | recipe-2 |
    Then bx displays
      """
      'recipe-1' invoked!
      'recipe-2' invoked!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      + # recipe-2 {
      + # }
      """
    And bx does not error out
    And bx succeeds

  Scenario: Invoke a mix of existing and missing recipes
    When invoking
      | RECIPE   |
      | recipe-1 |
      | missing  |
      | recipe-2 |
    Then bx displays
      """
      'recipe-1' invoked!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      """
    And bx errors out with message "bx: No recipe `missing`!"
    And bx fails
