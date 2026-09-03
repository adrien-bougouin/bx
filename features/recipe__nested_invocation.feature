Feature: Recipe--Nested Invocation

  Scenario: Invoke a recipe that invokes another recipe mid-execution
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke nested-recipe
        echo "Post-processing..."
      }

      nested-recipe() (
        echo "'nested-recipe' invoked!"
      )
      ```
    When executing bx with "recipe"
    Then bx displays
      """
      Pre-processing...
      'nested-recipe' invoked!
      Post-processing...
      """
    And bx traces
      """
      + # recipe {
      ++ # nested-recipe {
      ++ # }
      + # }
      """
    And bx does not error out

  Scenario: Invoke a recipe that invokes other recipes mid-execution
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke nested-recipe-1 nested-recipe-2
        bx::invoke nested-recipe-3
        echo "Post-processing..."
      }

      nested-recipe-1() (
        echo "'nested-recipe-1' invoked!"
      )

      nested-recipe-2() (
        echo "'nested-recipe-2' invoked!"
      )

      nested-recipe-3() (
        echo "'nested-recipe-3' invoked!"
      )
      ```
    When executing bx with "recipe"
    Then bx displays
      """
      Pre-processing...
      'nested-recipe-1' invoked!
      'nested-recipe-2' invoked!
      'nested-recipe-3' invoked!
      Post-processing...
      """
    And bx traces
      """
      + # recipe {
      ++ # nested-recipe-1 {
      ++ # }
      ++ # nested-recipe-2 {
      ++ # }
      ++ # nested-recipe-3 {
      ++ # }
      + # }
      """
    And bx does not error out

  Scenario: Invoke a recipe that invokes a missing recipe mid-execution
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke missing
        echo "Post-processing..."
      }
      ```
    When executing bx with "recipe"
    Then bx displays
      """
      Pre-processing...
      """
    And bx traces
      """
      + # recipe {
      """
    And bx errors out with message "bx: No recipe `missing`!"

  Scenario Outline: Invoke a recipe that invokes another recipe with arguments
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke 'nested-recipe <NESTED RECIPE ARGUMENTS>'
        echo "Post-processing..."
      }

      nested-recipe() {
        echo "'nested-recipe' invocation: \$#=$#, \$1='${1:-}', \$2='${2:-}'"
      }
      ```
    When executing bx with "recipe"
    Then bx displays
      """
      Pre-processing...
      'nested-recipe' invocation: <RECEIVED ARGUMENTS INFO>
      Post-processing...
      """
    And bx traces
      """
      + # recipe {
      ++ # nested-recipe <NESTED RECIPE ARGUMENTS> {
      ++ # }
      + # }
      """
    And bx does not error out

    Examples:
      | NESTED RECIPE ARGUMENTS | RECEIVED ARGUMENTS INFO      |
      | arg-1                   | $#=1, $1='arg-1', $2=''      |
      | arg-1 arg-2             | $#=2, $1='arg-1', $2='arg-2' |
      | arg\ 1 arg\ 2           | $#=2, $1='arg 1', $2='arg 2' |
      | "arg 1" "arg 2"         | $#=2, $1='arg 1', $2='arg 2' |

  Scenario: Invoke a recipe that invokes multiple recipes with arguments
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke nested-recipe 'nested-recipe arg-1' 'nested-recipe arg-2 arg-3'
        bx::invoke 'nested-recipe "arg 4" arg\ 5' nested-recipe
        echo "Post-processing..."
      }

      nested-recipe() (
        echo "'nested-recipe' invocation: \$#=$#, \$1='${1:-}', \$2='${2:-}'"
      )
      ```
    When executing bx with "recipe"
    Then bx displays
      """
      Pre-processing...
      'nested-recipe' invocation: $#=0, $1='', $2=''
      'nested-recipe' invocation: $#=1, $1='arg-1', $2=''
      'nested-recipe' invocation: $#=2, $1='arg-2', $2='arg-3'
      'nested-recipe' invocation: $#=2, $1='arg 4', $2='arg 5'
      'nested-recipe' invocation: $#=0, $1='', $2=''
      Post-processing...
      """
    And bx traces
      """
      + # recipe {
      ++ # nested-recipe {
      ++ # }
      ++ # nested-recipe arg-1 {
      ++ # }
      ++ # nested-recipe arg-2 arg-3 {
      ++ # }
      ++ # nested-recipe "arg 4" arg\ 5 {
      ++ # }
      ++ # nested-recipe {
      ++ # }
      + # }
      """
    And bx does not error out
