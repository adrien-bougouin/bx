Feature: Recipe--Nested Execution

  Scenario Outline: Run `bake` to execute a recipe that involves another recipe mid-execution
    Given the Bakefile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bake::recipes::execute <NESTED RECIPE ARGUMENTS>
        echo "Post-processing..."
      }

      simple-recipe() (
        echo "\$#=$#, \$1=${1:-}, \$2=${2:-}"
      )
      ```
    When running `bake` with arguments "complex-recipe"
    Then bake displays
      """
      complex-recipe
      Pre-processing...
      <EXECUTED NESTED RECIPE>
      <NESTED RECIPE OUTPUT>
      Post-processing...
      """
    And bake does not error out

    Examples:
      | NESTED RECIPE ARGUMENTS     | EXECUTED NESTED RECIPE    | NESTED RECIPE OUTPUT     |
      | simple-recipe               | simple-recipe             | $#=0, $1=, $2=           |
      | 'simple-recipe arg-1 arg-2' | simple-recipe arg-1 arg-2 | $#=2, $1=arg-1, $2=arg-2 |

  Scenario: Run `bake` to execute a recipe that involves other recipes mid-execution
    Given the Bakefile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bake::recipes::execute simple-recipe-1 'simple-recipe-2 arg-1 arg-2' simple-recipe-3
        echo "Post-processing..."
      }

      simple-recipe-1() (
        echo "'simple-recipe-1' execution: \$#=$#, \$1=${1:-}, \$2=${2:-}"
      )

      simple-recipe-2() (
        echo "'simple-recipe-2' execution: \$#=$#, \$1=${1:-}, \$2=${2:-}"
      )

      simple-recipe-3() (
        echo "'simple-recipe-3' execution: \$#=$#, \$1=${1:-}, \$2=${2:-}"
      )
      ```
    When running `bake` with arguments "complex-recipe"
    Then bake displays
      """
      complex-recipe
      Pre-processing...
      simple-recipe-1
      'simple-recipe-1' execution: $#=0, $1=, $2=
      simple-recipe-2 arg-1 arg-2
      'simple-recipe-2' execution: $#=2, $1=arg-1, $2=arg-2
      simple-recipe-3
      'simple-recipe-3' execution: $#=0, $1=, $2=
      Post-processing...
      """
    And bake does not error out

  Scenario: Run `bake` to execute a recipe that involves another missing recipe mid-execution
    Given the Bakefile
      ```bash
      complex-recipe() {
        echo "Pre-processing..."
        bake::recipes::execute missing
        echo "Post-processing..."
      }
      ```
    When running `bake` with arguments "complex-recipe"
    Then bake displays
      """
      complex-recipe
      Pre-processing...
      """
    And bake errors out with message "bake: No recipe 'missing'!"
