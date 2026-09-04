Feature: Recipe--Arguments

  Background:
    Given the Bashfile
      ```bash
      recipe-1() {
        echo "'recipe-1' invocation: \$#=$#, \$1='${1:-}', \$2='${2:-}'"
      }

      recipe-2() {
        echo "'recipe-2' invocation: \$#=$#, \$1='$1', \$2='$2'"
      }
      ```

  Scenario Outline: Invoke a recipe with arguments
    When executing bx with '\'recipe-1 <RECIPE ARGUMENTS>\''
    Then bx displays
      """
      'recipe-1' invocation: <RECEIVED ARGUMENTS INFO>
      """
    And bx traces
      """
      + # recipe-1 <RECIPE ARGUMENTS> {
      + # }
      """
    And bx does not error out

    Examples:
      | RECIPE ARGUMENTS            | RECEIVED ARGUMENTS INFO                  |
      | arg-1                       | $#=1, $1='arg-1', $2=''                  |
      | arg-1 arg-2                 | $#=2, $1='arg-1', $2='arg-2'             |
      | arg\ 1 arg\ 2               | $#=2, $1='arg 1', $2='arg 2'             |
      | "arg 1" "arg 2"             | $#=2, $1='arg 1', $2='arg 2'             |
      | --arg=arg\ 1 --arg=arg\ 2   | $#=2, $1='--arg=arg 1', $2='--arg=arg 2' |
      | --arg="arg 1" --arg="arg 2" | $#=2, $1='--arg=arg 1', $2='--arg=arg 2' |

  Scenario: Invoke multiple recipes with arguments
    When executing bx with "'recipe-1 arg-1 arg-2' 'recipe-2 arg-3 arg-4'"
    Then bx displays
      """
      'recipe-1' invocation: $#=2, $1='arg-1', $2='arg-2'
      'recipe-2' invocation: $#=2, $1='arg-3', $2='arg-4'
      """
    And bx traces
      """
      + # recipe-1 arg-1 arg-2 {
      + # }
      + # recipe-2 arg-3 arg-4 {
      + # }
      """
    And bx does not error out
