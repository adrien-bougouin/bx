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

      recipe() {
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
    And bx warns with message "bx: Skipping re-invocation of `<CIRCULAR RECIPE ARGUMENT>`..."

    Examples:
      | CIRCULAR RECIPE ARGUMENT |
      | recipe                   |
      | recipe arg-1 arg-2       |

  Scenario: Invoke a recipe that invokes itself with different arguments
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke 'recipe arg-1 arg-2'
        echo "Post-processing..."
      }
      ```
    When executing bx with "'recipe'"
    Then bx displays
      """
      Pre-processing...
      Pre-processing...
      Post-processing...
      Post-processing...
      """
    And bx traces
      """
      + # recipe {
      ++ # recipe arg-1 arg-2 {
      ++ # }
      + # }
      """
    And bx warns with message "bx: Skipping re-invocation of `recipe arg-1 arg-2`..."

  @todo
  # TODO: Normalize how we store the recipe arguments in the invocation stack
  Scenario: Invoke a recipe that invokes itself with same arguments formatted differently
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke "recipe ${@+"$(printf ' "%s"' "$@")"}"
        echo "Post-processing..."
      }
      ```
    When executing bx with "'recipe arg\ 1 arg\ 2'"
    Then bx displays
      """
      Pre-processing...
      Post-processing...
      """
    And bx traces
      """
      + # recipe "arg 1" "arg 2" {
      + # }
      """
    And bx warns with message 'bx: Skipping re-invocation of `recipe "arg 1" "arg 2"`...'
