Feature: Default Recipe

  A default recipe is a recipe invoked when executing bx without specifying
  any recipe to invoke.

  Scenario Outline: Invoke when there is a default recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }

      default-recipe() { @default; }
      ```
    When invoking
      | RECIPE   |
      | <RECIPE> |
    Then bx outputs to stderr
      | FORMAT | CONTENT          |
      | bx-in  | <INVOKED RECIPE> |
      | bx-out |                  |
    And bx succeeds

    Examples:
      | RECIPE             | INVOKED RECIPE     |
      |                    | default-recipe     |
      | non-default-recipe | non-default-recipe |

  Scenario: Invoke when there is no default recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }
      ```
    When invoking
    Then bx outputs to stderr
      | FORMAT   | CONTENT        |
      | bx-error | Nothing to do! |
    And bx fails

  Scenario: Invoke when the default is a private function instead of a recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }

      _not-a-recipe() { @default; }
      ```
    When invoking
    Then bx traces nothing
    And bx errors out with message "bx: Nothing to do!"
    And bx fails

  Scenario: Invoke an explicit recipe when there is no default recipe
    Given the Bashfile
      ```bash
      non-default-recipe() { :; }
      ```
    When invoking
      | RECIPE             |
      | non-default-recipe |
    Then bx outputs to stderr
      | FORMAT | CONTENT            |
      | bx-in  | non-default-recipe |
      | bx-out |                    |
    And bx succeeds

  Scenario Outline: Invoke when there are multiple default recipes
    Given the Bashfile
      ```bash
      default-recipe-1() { @default; }

      default-recipe-2() { @default; }
      ```
    When invoking
      | RECIPE   |
      | <RECIPE> |
    Then bx outputs nothing to stdout
    Then bx outputs to stderr
      | FORMAT   | CONTENT                   |
      | bx-error | Too many default recipes! |
    And bx fails

    Examples:
      | RECIPE           |
      |                  |
      | default-recipe-1 |
      | default-recipe-2 |
