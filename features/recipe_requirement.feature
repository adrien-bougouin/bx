Feature: Recipe Requirement

  Scenario: Run `bake` for a recipe that requires another one
    Given the Bakefile
      ```bash
      pre-recipe() { :; }

      recipe-with-requirement() { @require: pre-recipe; }
      ```
    When running `bake` with arguments "recipe-with-requirement"
    Then `bake` displays
      """
      pre-recipe
      recipe-with-requirement
      """
    And `bake` does not error out

  Scenario Outline: Run `bake` for a recipe that requires multiple recipes
    Given the Bakefile
      ```bash
      pre-recipe-1() { :; }

      pre-recipe-2() { :; }

      recipe-with-requirements() {
        @require: pre-recipe-1
        @require: pre-recipe-2
      }

      recipe-with-inline-requirements() {
        @require: pre-recipe-1  pre-recipe-2
      }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays
      """
      pre-recipe-1
      pre-recipe-2
      <RECIPE ARGUMENT>
      """
    And `bake` does not error out

    Examples:
      | RECIPE ARGUMENT                 |
      | recipe-with-requirements        |
      | recipe-with-inline-requirements |

  Scenario Outline: Run `bake` for a recipe that requires a missing recipe
    Given the Bakefile
      ```bash
      pre-recipe-1() { :; }

      pre-recipe-2() { :; }

      recipe-with-requirement() { @require: missing; }

      recipe-with-requirements() {
        @require: pre-recipe-1
        @require: missing
        @require: pre-recipe-2
      }

      recipe-with-inline-requirements() {
        @require: pre-recipe-1  missing pre-recipe-2
      }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays
      """
      <EXECUTED RECIPES>
      """
    And `bake` errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT                 | EXECUTED RECIPES | ERROR                      |
      | recipe-with-requirement         |                  | bake: No recipe 'missing'! |
      | recipe-with-requirements        | pre-recipe-1     | bake: No recipe 'missing'! |
      | recipe-with-inline-requirements | pre-recipe-1     | bake: No recipe 'missing'! |
