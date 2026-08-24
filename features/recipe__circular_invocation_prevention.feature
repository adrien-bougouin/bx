Feature: Recipe--Circular Invocation Prevention

  Circular invocation happens when a recipe tries to invoke itself (directly or
  indirectly--another invoked recipe re-invokes the parent recipe).

  Scenario Outline: Invoke a recipe that eventually invokes itself
    Given the Bashfile
      ```bash
      trap-recipe() {
        echo "Entering trap..."
        bx::invoke '<CIRCULAR RECIPE ARGUMENT>'
        echo "Exiting trap..."
      }

      complex-recipe() {
        echo "Pre-processing..."
        bx::invoke trap-recipe
        echo "Post-processing..."
      }
      ```
    When executing bx with "'<CIRCULAR RECIPE ARGUMENT>'"
    Then bx displays
      """
      Pre-processing...
      Entering trap...
      Exiting trap...
      Post-processing...
      """
    And bx traces
      """
      + # <CIRCULAR RECIPE ARGUMENT> {
      ++ # trap-recipe {
      ++ # }
      + # }
      """
    And bx warns with message "bx: Skipping re-invocation of '<CIRCULAR RECIPE ARGUMENT>'..."

    Examples:
      | CIRCULAR RECIPE ARGUMENT     |
      | complex-recipe               |
      | complex-recipe arg-1 arg-2   |

  Scenario: Invoke a recipe that invokes with different arguments
    Given the Bashfile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bx::invoke 'complex-recipe arg-1 arg-2'
        echo "Post-processing..."
      }
      ```
    When executing bx with "'complex-recipe'"
    Then bx displays
      """
      Pre-processing...
      Pre-processing...
      Post-processing...
      Post-processing...
      """
    And bx traces
      """
      + # complex-recipe {
      ++ # complex-recipe arg-1 arg-2 {
      ++ # }
      + # }
      """
    And bx warns with message "bx: Skipping re-invocation of 'complex-recipe arg-1 arg-2'..."
