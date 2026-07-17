Feature: Recipe--Arguments

  Background:
    Given the Bakefile
      ```bash
      do-something() {
        echo "'do-something' execution: \$#=$#, \$1=$1, \$2=$2"
      }

      do-something-else() {
        echo "'do-something-else' execution: \$#=$#, \$1=$1, \$2=$2"
      }
      ```

  Scenario: Run `bake` to execute a recipe with arguments
    When running `bake` with arguments "'do-something arg-1 arg-2'"
    Then `bake` displays
      """
      do-something arg-1 arg-2
      'do-something' execution: $#=2, $1=arg-1, $2=arg-2
      """
    And `bake` does not error out

  Scenario: Run `bake` to execute multiple recipes
    When running `bake` with arguments "'do-something arg-1 arg-2' 'do-something-else arg-3 arg-4'"
    Then `bake` displays
      """
      do-something arg-1 arg-2
      'do-something' execution: $#=2, $1=arg-1, $2=arg-2
      do-something-else arg-3 arg-4
      'do-something-else' execution: $#=2, $1=arg-3, $2=arg-4
      """
    And `bake` does not error out
