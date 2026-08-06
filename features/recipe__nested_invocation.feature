Feature: Recipe--Nested Invocation

  Scenario Outline: Invoke a recipe that invokes another recipe mid-execution
    Given the Bakefile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bake <NESTED RECIPE ARGUMENTS>
        echo "Post-processing..."
      }

      simple-recipe() (
        echo "\$#=$#, \$1=${1:-}, \$2=${2:-}"
      )
      ```
    When executing Bake with "complex-recipe"
    Then Bake displays
      """
      + complex-recipe
      Pre-processing...
      ++ <INVOKED NESTED RECIPE> ->
      <NESTED RECIPE OUTPUT>
      ++ <- <INVOKED NESTED RECIPE>
      Post-processing...
      """
    And Bake does not error out

    Examples:
      | NESTED RECIPE ARGUMENTS     | INVOKED NESTED RECIPE     | NESTED RECIPE OUTPUT     |
      | simple-recipe               | simple-recipe             | $#=0, $1=, $2=           |
      | 'simple-recipe arg-1 arg-2' | simple-recipe arg-1 arg-2 | $#=2, $1=arg-1, $2=arg-2 |

  Scenario: Invoke a recipe that invokes other recipes mid-execution
    Given the Bakefile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bake simple-recipe-1 'simple-recipe-2 arg-1 arg-2' simple-recipe-3
        bake simple-recipe-4
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
    When executing Bake with "complex-recipe"
    Then Bake displays
      """
      + complex-recipe
      Pre-processing...
      ++ simple-recipe-1 ->
      'simple-recipe-1' invocation: $#=0, $1=, $2=
      ++ <- simple-recipe-1
      ++ simple-recipe-2 arg-1 arg-2 ->
      'simple-recipe-2' invocation: $#=2, $1=arg-1, $2=arg-2
      ++ <- simple-recipe-2 arg-1 arg-2
      ++ simple-recipe-3 ->
      'simple-recipe-3' invocation: $#=0, $1=, $2=
      ++ <- simple-recipe-3
      ++ simple-recipe-4 ->
      'simple-recipe-4' invocation: $#=0, $1=, $2=
      ++ <- simple-recipe-4
      Post-processing...
      """
    And Bake does not error out

  Scenario: Invoke a recipe that invokes a missing recipe mid-execution
    Given the Bakefile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bake missing
        echo "Post-processing..."
      }
      ```
    When executing Bake with "complex-recipe"
    Then Bake displays
      """
      + complex-recipe
      Pre-processing...
      """
    And Bake errors out with message "bake: No recipe 'missing'!"
