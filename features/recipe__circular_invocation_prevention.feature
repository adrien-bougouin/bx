Feature: Recipe--Circular Invocation Prevention

  Circular invocation happens when a recipe tries to invoke itself (directly or
  indirectly--another invoked recipe re-invokes the parent recipe).

  Scenario Outline: Invoke a recipe that eventually invokes itself
    Given the Bashfile
      ```bash
      trap-recipe() {
        echo "Entering trap..."
        bx::invoke '<CIRCULAR RECIPE ARGUMENTS>'
        echo "Exiting trap..."
      }

      recipe() {
        echo "Pre-processing..."
        bx::invoke trap-recipe
        echo "Post-processing..."
      }
      ```
    When invoking
      | RECIPE                      |
      | <CIRCULAR RECIPE ARGUMENTS> |
    Then bx outputs to stdout
      """
      Pre-processing...
      Entering trap...
      Exiting trap...
      Post-processing...
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                     |
      | bx-trace-in  | <CIRCULAR RECIPE ARGUMENTS> |
      | bx-trace-in  | trap-recipe                 |
      | bx-skip      | <CIRCULAR RECIPE ARGUMENTS> |
      | bx-trace-out |                             |
      | bx-trace-out |                             |
    And bx succeeds

    Examples:
      | CIRCULAR RECIPE ARGUMENTS |
      | recipe                    |
      | recipe arg-1 arg-2        |

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
    Then bx outputs to stdout
      """
      Pre-processing...
      Pre-processing...
      Post-processing...
      Post-processing...
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT            |
      | bx-trace-in  | recipe             |
      | bx-trace-in  | recipe arg-1 arg-2 |
      | bx-skip      | recipe arg-1 arg-2 |
      | bx-trace-out |                    |
      | bx-trace-out |                    |
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
    Then bx outputs to stdout
      """
      Pre-processing...
      Post-processing...
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT              |
      | bx-trace-in  | recipe arg\ 1 arg\ 2 |
      | bx-skip      | recipe arg\ 1 arg\ 2 |
      | bx-trace-out |                      |
    And bx succeeds
