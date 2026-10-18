Feature: Recipe--Validation

  Scenario: Invoke a recipe with a valid annotation
    Given the Bashfile
      ```bash
        recipe--valid-annotation() {
          @default

          @help "Valid recipe."

          echo "'recipe--valid-annotation' invoked!"
        }
      ```
    When invoking
      | RECIPE                   |
      | recipe--valid-annotation |
    Then bx outputs to stdout
      """
      'recipe--valid-annotation' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                  |
      | bx-trace-in  | recipe--valid-annotation |
      | bx-trace-out |                          |
    And bx succeeds

  Scenario: Invoke a recipe with an invalid annotation
    Given the Bashfile
      ```bash
        recipe--invalid-annotation() {
          @default

          echo "'recipe--invalid-annotation' invoked!"

          @help "Invalid recipe."
        }
      ```
    When invoking
      | RECIPE                     |
      | recipe--invalid-annotation |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT   | CONTENT                                                                                                   |
      | bx-error | Invalid Bashfile at recipe `recipe--invalid-annotation` - Found annotation '@help' after executable code! |
    And bx fails

  Scenario: Invoke a valid recipe from a Bashfile with other invalid recipe
    Given the Bashfile
      ```bash
        recipe--valid-annotation() {
          @help "Valid recipe."

          echo "'recipe--valid-annotation' invoked!"
        }

        recipe--invalid-annotation() {
          echo "'recipe--invalid-annotation' invoked!"

          @help "Invalid recipe."
        }
      ```
    When invoking
      | RECIPE                   |
      | recipe--valid-annotation |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT   | CONTENT                                                                                                   |
      | bx-error | Invalid Bashfile at recipe `recipe--invalid-annotation` - Found annotation '@help' after executable code! |
    And bx fails
