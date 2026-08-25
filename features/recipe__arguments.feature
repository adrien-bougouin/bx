Feature: Recipe--Arguments

  Background:
    Given the Bashfile
      ```bash
      do-something() {
        echo "'do-something' invocation: \$#=$#, \$1=$1, \$2=$2"
      }

      do-something-else() {
        echo "'do-something-else' invocation: \$#=$#, \$1=$1, \$2=$2"
      }
      ```

  Scenario: Invoke a recipe with arguments
    When executing bx with "'do-something arg-1 arg-2'"
    Then bx displays
      """
      'do-something' invocation: $#=2, $1=arg-1, $2=arg-2
      """
    And bx traces
      """
      + # do-something arg-1 arg-2 {
      + # }
      """
    And bx does not error out

  Scenario: Invoke multiple recipes with arguments
    When executing bx with "'do-something arg-1 arg-2' 'do-something-else arg-3 arg-4'"
    Then bx displays
      """
      'do-something' invocation: $#=2, $1=arg-1, $2=arg-2
      'do-something-else' invocation: $#=2, $1=arg-3, $2=arg-4
      """
    And bx traces
      """
      + # do-something arg-1 arg-2 {
      + # }
      + # do-something-else arg-3 arg-4 {
      + # }
      """
    And bx does not error out
