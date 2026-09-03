Feature: Recipe--Arguments

  Background:
    Given the Bashfile
      ```bash
      do-something() {
        echo "'do-something' invocation: \$#=$#, \$1='${1:-}', \$2='${2:-}'"
      }

      do-something-else() {
        echo "'do-something-else' invocation: \$#=$#, \$1='$1', \$2='$2'"
      }
      ```

  Scenario Outline: Invoke a recipe with arguments
    When executing bx with '\'do-something <RECIPE ARGUMENTS>\''
    Then bx displays
      """
      'do-something' invocation: <RECEIVED ARGUMENTS INFO>
      """
    And bx traces
      """
      + # do-something <RECIPE ARGUMENTS> {
      + # }
      """
    And bx does not error out

    Examples:
      | RECIPE ARGUMENTS | RECEIVED ARGUMENTS INFO      |
      | arg-1            | $#=1, $1='arg-1', $2=''      |
      | arg-1 arg-2      | $#=2, $1='arg-1', $2='arg-2' |
      | arg\ 1 arg\ 2    | $#=2, $1='arg 1', $2='arg 2' |
      | "arg 1" "arg 2"  | $#=2, $1='arg 1', $2='arg 2' |

  Scenario: Invoke multiple recipes with arguments
    When executing bx with "'do-something arg-1 arg-2' 'do-something-else arg-3 arg-4'"
    Then bx displays
      """
      'do-something' invocation: $#=2, $1='arg-1', $2='arg-2'
      'do-something-else' invocation: $#=2, $1='arg-3', $2='arg-4'
      """
    And bx traces
      """
      + # do-something arg-1 arg-2 {
      + # }
      + # do-something-else arg-3 arg-4 {
      + # }
      """
    And bx does not error out
