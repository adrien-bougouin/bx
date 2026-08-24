Feature: Default Recipe

  A default recipe is a recipe invoked when executing bx without specifying
  any recipe to invoke.

  Scenario Outline: Invoke when there is a default recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }

      default-recipe() { @default; }
      ```
    When executing bx with "<RECIPE ARGUMENT>"
    Then bx traces
      """
      + # <INVOKED RECIPE> {
      + # }
      """
    And bx does not error out

    Examples:
      | RECIPE ARGUMENT    | INVOKED RECIPE     |
      |                    | default-recipe     |
      | non-default-recipe | non-default-recipe |

  Scenario: Invoke when there is no default recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }
      ```
    When executing bx with ""
    Then bx traces nothing
    And bx errors out with message "bx: Nothing to do!"

  Scenario: Invoke when the default is a private function instead of a recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }

      _not-a-recipe() { @default; }
      ```
    When executing bx with ""
    Then bx traces nothing
    And bx errors out with message "bx: Nothing to do!"

  Scenario: Invoke an explicit recipe when there is no default recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }
      ```
    When executing bx with "non-default-recipe"
    Then bx traces
      """
      + # non-default-recipe {
      + # }
      """
    And bx does not error out

  Scenario Outline: Invoke when there are multiple default recipes
    Given the Bashfile
      ```bash
      default-recipe-1() { @default; }

      default-recipe-2() { @default; }
      ```
    When executing bx with "<RECIPE ARGUMENT>"
    Then bx displays nothing
    And bx traces nothing
    And bx errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT  | ERROR                         |
      |                  | bx: Too many default recipes! |
      | default-recipe-1 | bx: Too many default recipes! |
      | default-recipe-2 | bx: Too many default recipes! |
