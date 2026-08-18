Feature: Recipe

  A recipe is a set of instructions invocable with Bake. A recipe is declared
  in a Bakefile as a Bash function. Private functions, prefixed by "_" by
  convention, are not treated as recipes.

  Background:
    Given the Bakefile
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
    When executing Bake with "recipe-1"
    Then Bake displays
      """
      'recipe-1' code executed!
      """
    And  Bake traces
      """
      + # recipe-1 {
      + # }
      """
    And Bake does not error out

  Scenario: Invoke a missing recipe
    When executing Bake with "missing"
    Then Bake displays nothing
    And Bake errors out with message "bake: No recipe 'missing'!"

  Scenario: Invoke a private function instead of a recipe
    When executing Bake with "_not-a-recipe"
    Then Bake displays nothing
    And Bake errors out with message "bake: '_not-a-recipe' is a private function, not a recipe!"

  Scenario: Invoke multiple recipes
    When executing Bake with "recipe-1 recipe-2"
    Then Bake displays
      """
      'recipe-1' code executed!
      'recipe-2' code executed!
      """
    And  Bake traces
      """
      + # recipe-1 {
      + # }
      + # recipe-2 {
      + # }
      """
    And Bake does not error out

  Scenario: Invoke a mix of existing and missing recipes
    When executing Bake with "recipe-1 missing recipe-2"
    Then Bake displays
      """
      'recipe-1' code executed!
      """
    And  Bake traces
      """
      + # recipe-1 {
      + # }
      """
    And Bake errors out with message "bake: No recipe 'missing'!"
