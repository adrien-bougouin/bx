Feature: Recipe--Circular Invocation Prevention

  Circular invocation happens when a recipe tries to invoke itself (directly or
  indirectly--another invoked recipe re-invokes the parent recipe).

  Scenario Outline: Invoke a recipe that eventually invokes itself
    Given the Bashfile
      ```bash
      trap-recipe() {
        echo "Entering trap..."
        bx::invoke 'recipe <RECIPE ARGUMENTS>'
        echo "Exiting trap..."
      }

      recipe() {
        echo "Pre-processing..."
        bx::invoke trap-recipe
        echo "Post-processing..."
      }
      ```
    When invoking
      | RECIPE                    |
      | recipe <RECIPE ARGUMENTS> |
    Then bx outputs
      | TYPE    | DATA                      |
      | bx-in   | recipe <RECIPE ARGUMENTS> |
      | stdout  | Pre-processing...         |
      | bx-in   | trap-recipe               |
      | stdout  | Entering trap...          |
      | bx-skip | recipe <RECIPE ARGUMENTS> |
      | stdout  | Exiting trap...           |
      | bx-out  |                           |
      | stdout  | Post-processing...        |
      | bx-out  |                           |
    And bx succeeds

    Examples:
      | RECIPE ARGUMENTS |
      |                  |
      | arg-1 arg-2      |

  Scenario: Invoke a recipe that invokes itself with different arguments
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke 'recipe arg-1 arg-2'
        echo "Post-processing..."
      }
      ```
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | TYPE    | DATA               |
      | bx-in   | recipe             |
      | stdout  | Pre-processing...  |
      | bx-in   | recipe arg-1 arg-2 |
      | stdout  | Pre-processing...  |
      | bx-skip | recipe arg-1 arg-2 |
      | stdout  | Post-processing... |
      | bx-out  |                    |
      | stdout  | Post-processing... |
      | bx-out  |                    |
    And bx succeeds

  Scenario: Invoke a recipe that invokes itself with same arguments formatted differently
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke 'recipe "arg 1" "arg 2"'
        echo "Post-processing..."
      }
      ```
    When invoking
      | RECIPE               |
      | recipe arg\ 1 arg\ 2 |
    Then bx outputs
      | TYPE    | DATA                   |
      | bx-in   | recipe arg\ 1 arg\ 2   |
      | stdout  | Pre-processing...      |
      | bx-skip | recipe "arg 1" "arg 2" |
      | stdout  | Post-processing...     |
      | bx-out  |                        |
    And bx succeeds
