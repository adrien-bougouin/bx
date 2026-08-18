Feature: Default Recipe

  A default recipe is a recipe invoked when executing Bake without specifying
  any recipe to invoke.

  Scenario Outline: Invoke when there is a default recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }

      default-recipe() { @default; }
      ```
    When executing Bake with "<RECIPE ARGUMENT>"
    Then Bake traces
      """
      + # <INVOKED RECIPE> {
      + # }
      """
    And Bake does not error out

    Examples:
      | RECIPE ARGUMENT    | INVOKED RECIPE     |
      |                    | default-recipe     |
      | non-default-recipe | non-default-recipe |

  Scenario: Invoke when there is no default recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }
      ```
    When executing Bake with ""
    Then Bake traces nothing
    And Bake errors out with message "bake: Nothing to do!"

  Scenario: Invoke when the default is a private function instead of a recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }

      _not-a-recipe() { @default; }
      ```
    When executing Bake with ""
    Then Bake traces nothing
    And Bake errors out with message "bake: Nothing to do!"

  Scenario: Invoke an explicit recipe when there is no default recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }
      ```
    When executing Bake with "non-default-recipe"
    Then Bake traces
      """
      + # non-default-recipe {
      + # }
      """
    And Bake does not error out

  Scenario Outline: Invoke when there are multiple default recipes
    Given the Bakefile
      ```bash
      default-recipe-1() { @default; }

      default-recipe-2() { @default; }
      ```
    When executing Bake with "<RECIPE ARGUMENT>"
    Then Bake displays nothing
    And Bake traces nothing
    And Bake errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT  | ERROR                           |
      |                  | bake: Too many default recipes! |
      | default-recipe-1 | bake: Too many default recipes! |
      | default-recipe-2 | bake: Too many default recipes! |
