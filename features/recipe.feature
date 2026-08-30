Feature: Recipe

  A recipe is a set of instructions declared in a Bashfile as a Bash function. A
  recipe is invoked by name; invoking a recipe executes its body. Private
  functions, prefixed by "_" by convention, are not treated as recipes.

  Background:
    Given the Bashfile
      ```bash
      recipe-1() {
        echo "'recipe-1' code executed!"
      }

      recipe-2() {
        echo "'recipe-2' code executed!"
      }

      _not-a-recipe() {
        echo "'_not-a-recipe' code executed!"
      }
      ```

  Scenario: Invoke a recipe
    When executing bx with "recipe-1"
    Then bx displays
      """
      'recipe-1' code executed!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      """
    And bx does not error out

  Scenario: Invoke a recipe multiple times
    When executing bx with "recipe-1 recipe-1"
    Then bx displays
      """
      'recipe-1' code executed!
      'recipe-1' code executed!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      + # recipe-1 {
      + # }
      """
    And bx does not error out

  Scenario: Invoke a missing recipe
    When executing bx with "missing"
    Then bx displays nothing
    And bx errors out with message "bx: No recipe 'missing'!"

  Scenario: Invoke a private function instead of a recipe
    When executing bx with "_not-a-recipe"
    Then bx displays nothing
    And bx errors out with message "bx: '_not-a-recipe' is a private function, not a recipe!"

  Scenario: Invoke multiple recipes
    When executing bx with "recipe-1 recipe-2"
    Then bx displays
      """
      'recipe-1' code executed!
      'recipe-2' code executed!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      + # recipe-2 {
      + # }
      """
    And bx does not error out

  Scenario: Invoke a mix of existing and missing recipes
    When executing bx with "recipe-1 missing recipe-2"
    Then bx displays
      """
      'recipe-1' code executed!
      """
    And bx traces
      """
      + # recipe-1 {
      + # }
      """
    And bx errors out with message "bx: No recipe 'missing'!"
