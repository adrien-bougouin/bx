Feature: Recipe--Nested Invocation

  Scenario: Invoke a recipe that invokes another recipe mid-execution
    Given the Bashfile
      ```bash
      composite-recipe() {
        echo "Pre-processing..."

        bx::invoke recipe

        echo "Post-processing..."
      }

      recipe() (
        echo "'recipe' invoked!"
      )
      ```
    When invoking
      | RECIPE           |
      | composite-recipe |
    Then bx outputs to stdout
      """
      Pre-processing...
      'recipe' invoked!
      Post-processing...
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT          |
      | bx-trace-in  | composite-recipe |
      | bx-trace-in  | recipe           |
      | bx-trace-out |                  |
      | bx-trace-out |                  |
    And bx succeeds

  Scenario: Invoke a recipe that invokes other recipes mid-execution
    Given the Bashfile
      ```bash
      composite-recipe() {
        echo "Pre-processing..."

        bx::invoke recipe-1 recipe-2
        bx::invoke recipe-3

        echo "Post-processing..."
      }

      recipe-1() (
        echo "'recipe-1' invoked!"
      )

      recipe-2() (
        echo "'recipe-2' invoked!"
      )

      recipe-3() (
        echo "'recipe-3' invoked!"
      )
      ```
    When invoking
      | RECIPE           |
      | composite-recipe |
    Then bx outputs to stdout
      """
      Pre-processing...
      'recipe-1' invoked!
      'recipe-2' invoked!
      'recipe-3' invoked!
      Post-processing...
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT          |
      | bx-trace-in  | composite-recipe |
      | bx-trace-in  | recipe-1         |
      | bx-trace-out |                  |
      | bx-trace-in  | recipe-2         |
      | bx-trace-out |                  |
      | bx-trace-in  | recipe-3         |
      | bx-trace-out |                  |
      | bx-trace-out |                  |
    And bx succeeds

  Scenario: Invoke a recipe that invokes a missing recipe mid-execution
    Given the Bashfile
      ```bash
      composite-recipe() {
        echo "Pre-processing..."

        bx::invoke missing

        echo "Post-processing..."
      }
      ```
    When invoking
      | RECIPE           |
      | composite-recipe |
    Then bx outputs to stdout
      """
      Pre-processing...
      """
    And bx outputs to stderr
      | FORMAT      | CONTENT          |
      | bx-trace-in | composite-recipe |
      | bx-miss     | missing          |
    And bx fails

  Scenario Outline: Invoke a recipe that invokes another recipe with arguments
    Given the Bashfile
      ```bash
      composite-recipe() {
        echo "Pre-processing..."

        bx::invoke 'recipe <NESTED RECIPE ARGUMENTS>'

        echo "Post-processing..."
      }

      recipe() {
        echo "'recipe' invocation: $#, '${1:-}', '${2:-}'"
      }
      ```
    When invoking
      | RECIPE           |
      | composite-recipe |
    Then bx outputs to stdout
      """
      Pre-processing...
      'recipe' invocation: <RECEIVED ARGUMENTS INFO>
      Post-processing...
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                          |
      | bx-trace-in  | composite-recipe                 |
      | bx-trace-in  | recipe <NESTED RECIPE ARGUMENTS> |
      | bx-trace-out |                                  |
      | bx-trace-out |                                  |
    And bx succeeds

    Examples:
      | NESTED RECIPE ARGUMENTS     | RECEIVED ARGUMENTS INFO         |
      | arg-1                       | 1, 'arg-1', ''                  |
      | arg-1 arg-2                 | 2, 'arg-1', 'arg-2'             |
      | arg\ 1 arg\ 2               | 2, 'arg 1', 'arg 2'             |
      | "arg 1" "arg 2"             | 2, 'arg 1', 'arg 2'             |
      | --arg=arg\ 1 --arg=arg\ 2   | 2, '--arg=arg 1', '--arg=arg 2' |
      | --arg="arg 1" --arg="arg 2" | 2, '--arg=arg 1', '--arg=arg 2' |

  Scenario: Invoke a recipe that invokes multiple recipes with arguments
    Given the Bashfile
      ```bash
      composite-recipe() {
        echo "Pre-processing..."

        bx::invoke recipe 'recipe arg-1' 'recipe arg-2 arg-3'
        bx::invoke 'recipe "arg 4" arg\ 5' recipe

        echo "Post-processing..."
      }

      recipe() (
        echo "'recipe' invocation: $#, '${1:-}', '${2:-}'"
      )
      ```
    When invoking
      | RECIPE           |
      | composite-recipe |
    Then bx outputs to stdout
      """
      Pre-processing...
      'recipe' invocation: 0, '', ''
      'recipe' invocation: 1, 'arg-1', ''
      'recipe' invocation: 2, 'arg-2', 'arg-3'
      'recipe' invocation: 2, 'arg 4', 'arg 5'
      'recipe' invocation: 0, '', ''
      Post-processing...
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT               |
      | bx-trace-in  | composite-recipe      |
      | bx-trace-in  | recipe                |
      | bx-trace-out |                       |
      | bx-trace-in  | recipe arg-1          |
      | bx-trace-out |                       |
      | bx-trace-in  | recipe arg-2 arg-3    |
      | bx-trace-out |                       |
      | bx-trace-in  | recipe "arg 4" arg\ 5 |
      | bx-trace-out |                       |
      | bx-trace-in  | recipe                |
      | bx-trace-out |                       |
      | bx-trace-out |                       |
    And bx succeeds
