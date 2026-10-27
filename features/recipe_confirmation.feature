Feature: Recipe Confirmation

  Background:
    Given the Bashfile
      ```bash
      destructive-recipe-1() {
        @confirm

        echo "'destructive-recipe-1' invoked!"
      }

      destructive-recipe-2() {
        @confirm

        echo "'destructive-recipe-2' invoked!"
      }
      ```

  Scenario Outline: Confirm a recipe invocation
    When invoking
      | RECIPE               | CONFIRMATION         |
      | destructive-recipe-1 | <CONFIRMATION INPUT> |
    Then bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT              |
      | bx-confirm   | destructive-recipe-1 |
      | bx-trace-in  | destructive-recipe-1 |
      | bx-trace-out |                      |
    And bx succeeds

    Examples:
      | CONFIRMATION INPUT |
      | y                  |
      | Y                  |

  Scenario Outline: Confirm a recipe invocation with arguments
    When invoking
      | RECIPE                                  | CONFIRMATION |
      | destructive-recipe-1 <RECIPE ARGUMENTS> | y            |
    Then bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                                 |
      | bx-confirm   | destructive-recipe-1 <RECIPE ARGUMENTS> |
      | bx-trace-in  | destructive-recipe-1 <RECIPE ARGUMENTS> |
      | bx-trace-out |                                         |
    And bx succeeds

    Examples:
      | RECIPE ARGUMENTS            |
      | arg-1                       |
      | arg-1 arg-2                 |
      | arg\ 1 arg\ 2               |
      | "arg 1" "arg 2"             |
      | --arg=arg\ 1 --arg=arg\ 2   |
      | --arg="arg 1" --arg="arg 2" |

  Scenario: Confirm multiple recipe invocations
    When invoking
      | RECIPE               | CONFIRMATION |
      | destructive-recipe-1 | y            |
      | destructive-recipe-2 | y            |
    Then bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      'destructive-recipe-2' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT              |
      | bx-confirm   | destructive-recipe-1 |
      | bx-trace-in  | destructive-recipe-1 |
      | bx-trace-out |                      |
      | bx-confirm   | destructive-recipe-2 |
      | bx-trace-in  | destructive-recipe-2 |
      | bx-trace-out |                      |
    And bx succeeds

  Scenario Outline: Reject a recipe invocation
    When invoking
      | RECIPE               | CONFIRMATION      |
      | destructive-recipe-1 | <REJECTION INPUT> |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT     | CONTENT              |
      | bx-confirm | destructive-recipe-1 |
      | bx-error   | Aborted!             |
    And bx fails

    Examples:
      | REJECTION INPUT |
      | ?               |
      | n               |
      | N               |

  Scenario: Confirm then reject recipe invocations
    When invoking
      | RECIPE               | CONFIRMATION |
      | destructive-recipe-1 | y            |
      | destructive-recipe-2 | n            |
    Then bx outputs to stdout
      """
      'destructive-recipe-1' invoked!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT              |
      | bx-confirm   | destructive-recipe-1 |
      | bx-trace-in  | destructive-recipe-1 |
      | bx-trace-out |                      |
      | bx-confirm   | destructive-recipe-2 |
      | bx-error     | Aborted!             |
    And bx fails
