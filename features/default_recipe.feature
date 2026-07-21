Feature: Default Recipe

  A default recipe is a recipe invoked when running `bake` without specifying
  any recipe to invoke. There should be only one default recipe, usually
  assigned using the annotation `@default`.

  Scenario Outline: Run `bake` when there is a default recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }

      default-recipe() { @default; }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays
      """
      <EXECUTED RECIPE>
      """
    And `bake` does not error out

    Examples:
      | RECIPE ARGUMENT    | EXECUTED RECIPE    |
      |                    | default-recipe     |
      | non-default-recipe | non-default-recipe |

  Scenario Outline: Run `bake` when there is no explicit default recipe
    Given the Bakefile
      ```bash
      non-default-recipe() { :; }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays
      """
      <EXECUTED RECIPE>
      """
      And `bake` errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT    | EXECUTED RECIPE    | ERROR                |
      |                    |                    | bake: Nothing to do! |
      | non-default-recipe | non-default-recipe |                      |

  Scenario Outline: Run `bake` when there are more than one default recipe
    Given the Bakefile
      ```bash
      default-recipe-1() { @default; }

      default-recipe-2() { @default; }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays nothing
    And `bake` errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT  | ERROR                           |
      |                  | bake: Too many default recipes! |
      | default-recipe-1 | bake: Too many default recipes! |
      | default-recipe-2 | bake: Too many default recipes! |
