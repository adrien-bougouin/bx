Feature: Recipe--Circular Invocation Prevention

  Circular invocation happens when a recipe tries to invoke itself (directly or
  indirectly--another invoked recipe re-invokes the parent recipe).

  Scenario Outline: Invoke a recipe that eventually invokes itself
    Given the Bakefile
      ```bash
      trap-recipe() {
        echo "Entering trap..."
        bake::invoke '<CIRCULAR RECIPE ARGUMENT>'
        echo "Exiting trap..."
      }

      complex-recipe() {
        echo "Pre-processing..."
        bake::invoke trap-recipe
        echo "Post-processing..."
      }
      ```
    When executing Bake with "'<CIRCULAR RECIPE ARGUMENT>'"
    Then Bake displays
      """
      Pre-processing...
      Entering trap...
      Exiting trap...
      Post-processing...
      """
    And Bake traces
      """
      + # <CIRCULAR RECIPE ARGUMENT> {
      ++ # trap-recipe {
      ++ # }
      + # }
      """
    And Bake warns with message "bake: Skipping re-invocation of '<CIRCULAR RECIPE ARGUMENT>'..."

    Examples:
      | CIRCULAR RECIPE ARGUMENT     |
      | complex-recipe               |
      | complex-recipe arg-1 arg-2   |

  Scenario: Invoke a recipe that invokes with different arguments
    Given the Bakefile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bake::invoke 'complex-recipe arg-1 arg-2'
        echo "Post-processing..."
      }
      ```
    When executing Bake with "'complex-recipe'"
    Then Bake displays
      """
      Pre-processing...
      Pre-processing...
      Post-processing...
      Post-processing...
      """
    And Bake traces
      """
      + # complex-recipe {
      ++ # complex-recipe arg-1 arg-2 {
      ++ # }
      + # }
      """
    And Bake warns with message "bake: Skipping re-invocation of 'complex-recipe arg-1 arg-2'..."
