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
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | FORMAT | DATA                     |
      | bx-in  | recipe                   |
      |        | Pre-processing...        |
      | bx-in  | nested-recipe            |
      |        | 'nested-recipe' invoked! |
      | bx-out |                          |
      |        | Post-processing...       |
      | bx-out |                          |
    And bx succeeds

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
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | FORMAT | DATA                       |
      | bx-in  | recipe                     |
      |        | Pre-processing...          |
      | bx-in  | nested-recipe-1            |
      |        | 'nested-recipe-1' invoked! |
      | bx-out |                            |
      | bx-in  | nested-recipe-2            |
      |        | 'nested-recipe-2' invoked! |
      | bx-out |                            |
      | bx-in  | nested-recipe-3            |
      |        | 'nested-recipe-3' invoked! |
      | bx-out |                            |
      |        | Post-processing...         |
      | bx-out |                            |
    And bx succeeds

  Scenario: Invoke a recipe that invokes a missing recipe mid-execution
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke missing
        echo "Post-processing..."
      }
      ```
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | FORMAT   | DATA                 |
      | bx-in    | recipe               |
      |          | Pre-processing...    |
      | bx-error | No recipe `missing`! |
    And bx fails

  Scenario Outline: Invoke a recipe that invokes another recipe with arguments
    Given the Bashfile
      ```bash
      recipe() {
        echo "Pre-processing..."
        bx::invoke 'nested-recipe <NESTED RECIPE ARGUMENTS>'
        echo "Post-processing..."
      }

      nested-recipe() {
        echo "'nested-recipe' invocation: $#, '${1:-}', '${2:-}'"
      }
      ```
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | FORMAT | DATA                                                  |
      | bx-in  | recipe                                                |
      |        | Pre-processing...                                     |
      | bx-in  | nested-recipe <NESTED RECIPE ARGUMENTS>               |
      |        | 'nested-recipe' invocation: <RECEIVED ARGUMENTS INFO> |
      | bx-out |                                                       |
      |        | Post-processing...                                    |
      | bx-out |                                                       |
    And bx succeeds

    Examples:
      | NESTED RECIPE ARGUMENTS     | RECEIVED ARGUMENTS INFO        |
      | arg-1                       | 1, 'arg-1', ''                 |
      | arg-1 arg-2                 | 2, 'arg-1', 'arg-2'            |
      | arg\ 1 arg\ 2               | 2, 'arg 1', 'arg 2'            |
      | "arg 1" "arg 2"             | 2, 'arg 1', 'arg 2'            |
      | --arg=arg\ 1 --arg=arg\ 2   | 2, '--arg=arg 1', '--arg=arg 2'|
      | --arg="arg 1" --arg="arg 2" | 2, '--arg=arg 1', '--arg=arg 2'|

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
        echo "'nested-recipe' invocation: $#, '${1:-}', '${2:-}'"
      )
      ```
    When invoking
      | RECIPE |
      | recipe |
    Then bx outputs
      | FORMAT | DATA                                            |
      | bx-in  | recipe                                          |
      |        | Pre-processing...                               |
      | bx-in  | nested-recipe                                   |
      |        | 'nested-recipe' invocation: 0, '', ''           |
      | bx-out |                                                 |
      | bx-in  | nested-recipe arg-1                             |
      |        | 'nested-recipe' invocation: 1, 'arg-1', ''      |
      | bx-out |                                                 |
      | bx-in  | nested-recipe arg-2 arg-3                       |
      |        | 'nested-recipe' invocation: 2, 'arg-2', 'arg-3' |
      | bx-out |                                                 |
      | bx-in  | nested-recipe "arg 4" arg\ 5                    |
      |        | 'nested-recipe' invocation: 2, 'arg 4', 'arg 5' |
      | bx-out |                                                 |
      | bx-in  | nested-recipe                                   |
      |        | 'nested-recipe' invocation: 0, '', ''           |
      | bx-out |                                                 |
      |        | Post-processing...                              |
      | bx-out |                                                 |
    And bx succeeds
