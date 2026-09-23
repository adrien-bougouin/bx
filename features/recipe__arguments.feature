Feature: Recipe--Arguments

  Background:
    Given the Bashfile
      ```bash
      recipe-1() {
        echo "'recipe-1' invocation: $#, '${1:-}', '${2:-}'"
      }

      recipe-2() {
        echo "'recipe-2' invocation: $#, '$1', '$2'"
      }
      ```

  Scenario Outline: Invoke a recipe with arguments
    When invoking
      | RECIPE                      |
      | recipe-1 <RECIPE ARGUMENTS> |
    Then bx outputs
      | TYPE   | DATA                                             |
      | bx-in  | recipe-1 <RECIPE ARGUMENTS>                      |
      |        | 'recipe-1' invocation: <RECEIVED ARGUMENTS INFO> |
      | bx-out |                                                  |
    And bx succeeds

    Examples:
      | RECIPE ARGUMENTS        | RECEIVED ARGUMENTS INFO     |
      | arg-1                   | 1, 'arg-1', ''              |
      | arg-1 arg-2             | 2, 'arg-1', 'arg-2'         |
      | arg\ 1 arg\ 2           | 2, 'arg 1', 'arg 2'         |
      | "arg 1" "arg 2"         | 2, 'arg 1', 'arg 2'         |
      | --arg=a\ 1 --arg=b\ 2   | 2, '--arg=a 1', '--arg=b 2' |
      | --arg="a 1" --arg="b 2" | 2, '--arg=a 1', '--arg=b 2' |

  Scenario: Invoke multiple recipes with arguments
    When invoking
      | RECIPE               |
      | recipe-1 arg-1 arg-2 |
      | recipe-2 arg-3 arg-4 |
    Then bx outputs
      | TYPE   | DATA                                       |
      | bx-in  | recipe-1 arg-1 arg-2                       |
      |        | 'recipe-1' invocation: 2, 'arg-1', 'arg-2' |
      | bx-out |                                            |
      | bx-in  | recipe-2 arg-3 arg-4                       |
      |        | 'recipe-2' invocation: 2, 'arg-3', 'arg-4' |
      | bx-out |                                            |
    And bx succeeds
