Feature: Default Recipe

  A default recipe is a recipe invoked when executing Bake without specifying
  any recipe to invoke.

  Scenario Outline: Invoke when there is a default recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }

      default-recipe() { @default; }
      ```
    When executing Bake with arguments "<RECIPE ARGUMENT>"
    Then Bake displays
      """
      <INVOKED RECIPE>
      """
    And Bake does not error out

    Examples:
      | RECIPE ARGUMENT    | INVOKED RECIPE     |
      |                    | default-recipe     |
      | non-default-recipe | non-default-recipe |

  Scenario Outline: Invoke when there is no default recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }
      ```
    When executing Bake with arguments "<RECIPE ARGUMENT>"
    Then Bake displays
      """
      <INVOKED RECIPE>
      """
      And Bake errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT    | INVOKED RECIPE     | ERROR                |
      |                    |                    | bake: Nothing to do! |
      | non-default-recipe | non-default-recipe |                      |

  Scenario Outline: Invoke when there are multiple default recipes
    Given the Bakefile
      ```bash
      default-recipe-1() { @default; }

      default-recipe-2() { @default; }
      ```
    When executing Bake with arguments "<RECIPE ARGUMENT>"
    Then Bake displays nothing
    And Bake errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT  | ERROR                           |
      |                  | bake: Too many default recipes! |
      | default-recipe-1 | bake: Too many default recipes! |
      | default-recipe-2 | bake: Too many default recipes! |
