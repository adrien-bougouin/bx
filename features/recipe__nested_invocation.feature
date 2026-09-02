Feature: Recipe--Nested Invocation

  Scenario Outline: Invoke a recipe that invokes another recipe mid-execution
    Given the Bashfile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bx::invoke <NESTED RECIPE ARGUMENTS>
        echo "Post-processing..."
      }

      simple-recipe() (
        echo "\$#=$#, \$1=${1:-}, \$2=${2:-}"
      )
      ```
    When executing bx with "complex-recipe"
    Then bx displays
      """
      Pre-processing...
      <NESTED RECIPE OUTPUT>
      Post-processing...
      """
    And bx traces
      """
      + # complex-recipe {
      ++ # <INVOKED NESTED RECIPE> {
      ++ # }
      + # }
      """
    And bx does not error out

    Examples:
      | NESTED RECIPE ARGUMENTS     | INVOKED NESTED RECIPE     | NESTED RECIPE OUTPUT     |
      | simple-recipe               | simple-recipe             | $#=0, $1=, $2=           |
      | 'simple-recipe arg-1 arg-2' | simple-recipe arg-1 arg-2 | $#=2, $1=arg-1, $2=arg-2 |

  Scenario: Invoke a recipe that invokes other recipes mid-execution
    Given the Bashfile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bx::invoke simple-recipe-1 'simple-recipe-2 arg-1 arg-2' simple-recipe-3
        bx::invoke simple-recipe-4
        echo "Post-processing..."
      }

      simple-recipe-1() (
        echo "'simple-recipe-1' invocation: \$#=$#, \$1=${1:-}, \$2=${2:-}"
      )

      simple-recipe-2() (
        echo "'simple-recipe-2' invocation: \$#=$#, \$1=${1:-}, \$2=${2:-}"
      )

      simple-recipe-3() (
        echo "'simple-recipe-3' invocation: \$#=$#, \$1=${1:-}, \$2=${2:-}"
      )

      simple-recipe-4() (
        echo "'simple-recipe-4' invocation: \$#=$#, \$1=${1:-}, \$2=${2:-}"
      )
      ```
    When executing bx with "complex-recipe"
    Then bx displays
      """
      Pre-processing...
      'simple-recipe-1' invocation: $#=0, $1=, $2=
      'simple-recipe-2' invocation: $#=2, $1=arg-1, $2=arg-2
      'simple-recipe-3' invocation: $#=0, $1=, $2=
      'simple-recipe-4' invocation: $#=0, $1=, $2=
      Post-processing...
      """
    And bx traces
      """
      + # complex-recipe {
      ++ # simple-recipe-1 {
      ++ # }
      ++ # simple-recipe-2 arg-1 arg-2 {
      ++ # }
      ++ # simple-recipe-3 {
      ++ # }
      ++ # simple-recipe-4 {
      ++ # }
      + # }
      """
    And bx does not error out

  Scenario: Invoke a recipe that invokes a missing recipe mid-execution
    Given the Bashfile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bx::invoke missing
        echo "Post-processing..."
      }
      ```
    When executing bx with "complex-recipe"
    Then bx displays
      """
      Pre-processing...
      """
    And bx traces
      """
      + # complex-recipe {
      """
    And bx errors out with message "bx: No recipe `missing`!"
