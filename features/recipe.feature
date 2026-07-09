Feature: Recipe

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

  Scenario: Run `bake` to execute a recipe
    When running `bake` with arguments "do-something"
    Then bake displays
      """
      do-something
      'do-something' code executed!
      """
    And bake does not error out

  Scenario: Run `bake` to execute a missing recipe
    When running `bake` with arguments "missing"
    Then bake displays nothing
    And bake errors out with message "bake: No recipe 'missing'!"

  Scenario: Run `bake` to execute multiple recipes
    When running `bake` with arguments "do-something do-something-else"
    Then bake displays
      """
      do-something
      'do-something' code executed!
      do-something-else
      'do-something-else' code executed!
      """
    And bake does not error out

  Scenario: Run `bake` to execute a missing recipe among others
    When running `bake` with arguments "do-something missing do-something-else"
    Then bake displays
      """
      do-something
      'do-something' code executed!
      """
    And bake errors out with message "bake: No recipe 'missing'!"
