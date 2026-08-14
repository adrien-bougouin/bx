Feature: Recipe Requirement

  A recipe can require other recipes to be invoked first.

  Scenario: Invoke a recipe that requires another one
    Given the Bakefile
      ```bash
      pre-recipe() { :; }

      recipe-with-requirement() { @require: pre-recipe; }
      ```
    When executing Bake with "recipe-with-requirement"
    Then Bake traces
      """
      + # pre-recipe {
      + # }
      + # recipe-with-requirement {
      + # }
      """
    And Bake does not error out

  Scenario Outline: Invoke a recipe that requires multiple recipes
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
    When executing Bake with "<RECIPE ARGUMENT>"
    Then Bake traces
      """
      + # pre-recipe-1 {
      + # }
      + # pre-recipe-2 {
      + # }
      + # <RECIPE ARGUMENT> {
      + # }
      """
    And Bake does not error out

    Examples:
      | RECIPE ARGUMENT                 |
      | recipe-with-requirements        |
      | recipe-with-inline-requirements |

  Scenario: Invoke a recipe that requires a missing recipe
    Given the Bakefile
      ```bash
      recipe() {
        @require: missing
      }
      ```
    When executing Bake with "recipe"
    Then Bake traces nothing
    And Bake errors out with message "bake: No recipe 'missing'!"

  Scenario Outline: Invoke a recipe that requires a missing recipe among others
    Given the Bakefile
      ```bash
      pre-recipe-1() { :; }

      pre-recipe-2() { :; }

      recipe-with-requirements() {
        @require: pre-recipe-1
        @require: missing
        @require: pre-recipe-2
      }

      recipe-with-inline-requirements() {
        @require: pre-recipe-1  missing pre-recipe-2
      }
      ```
    When executing Bake with "<RECIPE ARGUMENT>"
    Then Bake traces
      """
      + # pre-recipe-1 {
      + # }
      """
    And Bake errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT                 | ERROR                      |
      | recipe-with-requirements        | bake: No recipe 'missing'! |
      | recipe-with-inline-requirements | bake: No recipe 'missing'! |
