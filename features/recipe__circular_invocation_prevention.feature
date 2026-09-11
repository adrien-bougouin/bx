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
    When executing bx with "'<CIRCULAR RECIPE ARGUMENTS>'"
    Then bx displays
      """
      Pre-processing...
      Entering trap...
      Exiting trap...
      Post-processing...
      """
    And bx traces
      """
      + # <TRACED RECIPE ARGUMENTS> {
      ++ # trap-recipe {
      ++ # }
      + # }
      """
    And bx warns with message "bx: Skipping re-invocation of `<TRACED RECIPE ARGUMENTS>`..."

    Examples:
      | CIRCULAR RECIPE ARGUMENTS | TRACED RECIPE ARGUMENTS |
      | recipe                    | recipe                  |
      | recipe arg-1 arg-2        | recipe 'arg-1' 'arg-2'  |

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
      ++ # recipe 'arg-1' 'arg-2' {
      ++ # }
      + # }
      """
    And bx warns with message "bx: Skipping re-invocation of `recipe 'arg-1' 'arg-2'`..."

  Scenario: Invoke a recipe that invokes itself with same arguments formatted differently
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke 'recipe "arg 1" "arg 2"'
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
      + # recipe 'arg\ 1' 'arg\ 2' {
      + # }
      """
      And bx warns with message "bx: Skipping re-invocation of `recipe 'arg\ 1' 'arg\ 2'`..."
