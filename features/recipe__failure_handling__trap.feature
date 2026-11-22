Feature: Recipe--Failure Handling--Trap

  bx uses an EXIT trap to report failed recipes and their exit status.

  Background:
    Given the Bashfile
      ```bash
      recipe--with-cleanup() {
        trap 'echo "Cleaning up after failure with status $?!"' EXIT
        trap 'echo "Interrupted!"' INT

        exit 42
      }

      recipe--with-failing-cleanup() {
        trap 'echo "Cleanup failed!"; false' EXIT

        false
      }

      recipe--with-cleanup-reset() {
        trap 'echo "Cleaning up after failure!"' EXIT
        if [[ ${WITH_DOUBLE_SLASH:-} == 1 ]]; then
          trap -- - EXIT
        else
          trap - EXIT
        fi

        false
      }

      recipe--with-invalid-cleanup() {
        trap -o bogus EXIT
      }

      recipe--with-cleanup-and-invalid-trap() {
        trap 'echo "Cleaning up after failure!"' EXIT
        trap -o bogus EXIT
      }
      ```

  Scenario: Invoke a failing recipe that cleans up on exit
    When invoking
      | RECIPE               |
      | recipe--with-cleanup |
    Then bx outputs to stdout
      """
      Cleaning up after failure with status 42!
      """
    And bx outputs to stderr
      | FORMAT      | CONTENT                                              |
      | bx-trace-in | recipe--with-cleanup                                 |
      | bx-error    | Recipe `recipe--with-cleanup` exited with status 42! |
    And bx fails

  Scenario: Invoke a failing recipe whose cleanup handler also fails
    When invoking
      | RECIPE                       |
      | recipe--with-failing-cleanup |
    Then bx outputs to stdout
      """
      Cleanup failed!
      """
    And bx outputs to stderr
      | FORMAT      | CONTENT                                                     |
      | bx-trace-in | recipe--with-failing-cleanup                                |
      | bx-error    | Recipe `recipe--with-failing-cleanup` exited with status 1! |
    And bx fails

  Scenario Outline: Invoke a failing recipe that clears its cleanup handler
    Given the shell environment
      ```bash
      export WITH_DOUBLE_SLASH=<WITH DOUBLE SLASH>
      ```
    When invoking
      | RECIPE                     |
      | recipe--with-cleanup-reset |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT      | CONTENT                                                   |
      | bx-trace-in | recipe--with-cleanup-reset                                |
      | bx-error    | Recipe `recipe--with-cleanup-reset` exited with status 1! |
    And bx fails

    Examples:
      | WITH DOUBLE SLASH |
      | 0                 |
      | 1                 |

  Scenario: Invoke a recipe with an invalid cleanup handler
    When invoking
      | RECIPE                       |
      | recipe--with-invalid-cleanup |
    Then bx outputs nothing to stdout
    And bx outputs to stderr
      | FORMAT       | CONTENT                                                     |
      | bx-trace-in  | recipe--with-invalid-cleanup                                |
      |              | /Bashfile: line 26: trap -o bogus EXIT: invalid usage$/     |
      | bx-error     | Recipe `recipe--with-invalid-cleanup` exited with status 2! |
    And bx fails

  Scenario: Invoke a failing recipe with an invalid trap after a cleanup
    When invoking
      | RECIPE                                |
      | recipe--with-cleanup-and-invalid-trap |
    Then bx outputs to stdout
      """
      Cleaning up after failure!
      """
    And bx outputs to stderr
      | FORMAT       | CONTENT                                                              |
      | bx-trace-in  | recipe--with-cleanup-and-invalid-trap                                |
      |              | /Bashfile: line 31: trap -o bogus EXIT: invalid usage$/               |
      | bx-error     | Recipe `recipe--with-cleanup-and-invalid-trap` exited with status 2! |
    And bx fails
