Feature: Recipe--Arguments

  Background:
    Given the Bakefile
      ```bash
      do-something() {
        echo "'do-something' invocation: \$#=$#, \$1=$1, \$2=$2"
      }

      do-something-else() {
        echo "'do-something-else' invocation: \$#=$#, \$1=$1, \$2=$2"
      }
      ```

  Scenario: Execute Bake to invoke a recipe with arguments
    When executing Bake with arguments "'do-something arg-1 arg-2'"
    Then Bake displays
      """
      do-something arg-1 arg-2
      'do-something' invocation: $#=2, $1=arg-1, $2=arg-2
      """
    And Bake does not error out

  Scenario: Execute Bake to invoke multiple recipes
    When executing Bake with arguments "'do-something arg-1 arg-2' 'do-something-else arg-3 arg-4'"
    Then Bake displays
      """
      do-something arg-1 arg-2
      'do-something' invocation: $#=2, $1=arg-1, $2=arg-2
      do-something-else arg-3 arg-4
      'do-something-else' invocation: $#=2, $1=arg-3, $2=arg-4
      """
    And Bake does not error out
