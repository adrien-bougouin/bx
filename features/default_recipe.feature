Feature: Default Recipe

  A default recipe is a recipe invoked when executing Bake without specifying
  any recipe to invoke. There should be only one default recipe, usually
  assigned using the annotation `@default`.

  Scenario Outline: Execute Bake when there is a default recipe
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

  Scenario Outline: Execute Bake when there is no explicit default recipe
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

  Scenario Outline: Execute Bake when there are more than one default recipe
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
