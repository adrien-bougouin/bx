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

  Scenario: Execute Bake to invoke a recipe
    When executing Bake with arguments "do-something"
    Then Bake displays
      """
      do-something
      'do-something' code executed!
      """
    And Bake does not error out

  Scenario: Execute Bake to invoke a missing recipe
    When executing Bake with arguments "missing"
    Then Bake displays nothing
    And Bake errors out with message "bake: No recipe 'missing'!"

  Scenario: Execute Bake to invoke multiple recipes
    When executing Bake with arguments "do-something do-something-else"
    Then Bake displays
      """
      do-something
      'do-something' code executed!
      do-something-else
      'do-something-else' code executed!
      """
    And Bake does not error out

  Scenario: Execute Bake to invoke a missing recipe among others
    When executing Bake with arguments "do-something missing do-something-else"
    Then Bake displays
      """
      do-something
      'do-something' code executed!
      """
    And Bake errors out with message "bake: No recipe 'missing'!"
