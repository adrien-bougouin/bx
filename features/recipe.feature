Feature: Recipe

  A recipe is a set of instructions invocable with Bake. A recipe is declared
  in a Bakefile as a Bash function.

  Background:
    Given the Bakefile
      ```bash
      do-something() {
        echo "'do-something' code executed!"
      }

      do-something-else() {
        echo "'do-something-else' code executed!"
      }
      ```

  Scenario: Invoke a recipe
    When executing Bake with "do-something"
    Then Bake displays
      """
      + do-something
      'do-something' code executed!
      """
    And Bake does not error out

  Scenario: Invoke a missing recipe
    When executing Bake with "missing"
    Then Bake displays nothing
    And Bake errors out with message "bake: No recipe 'missing'!"

  Scenario: Invoke multiple recipes
    When executing Bake with "do-something do-something-else"
    Then Bake displays
      """
      + do-something
      'do-something' code executed!
      + do-something-else
      'do-something-else' code executed!
      """
    And Bake does not error out

  Scenario: Invoke a mix of existing and missing recipes
    When executing Bake with "do-something missing do-something-else"
    Then Bake displays
      """
      + do-something
      'do-something' code executed!
      """
    And Bake errors out with message "bake: No recipe 'missing'!"
