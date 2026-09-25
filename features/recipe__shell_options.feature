Feature: Recipe--Shell Options

  A recipe can change the shell options locally. The shell option changes do not
  affect bx or other recipes.

  Scenario: Invoke multiple recipes when one sets xtrace
    Given the Bashfile
      ```bash
      hello-xtrace() {
        set -x

        echo "Hello"
      }

      world() {
        echo "World!"
      }
      ```
    When invoking
      | RECIPE       |
      | hello-xtrace |
      | world        |
    Then bx outputs to stdout
      """
      Hello
      World!
      """
    And bx traces
      """
      + # hello-xtrace {
      ++ echo Hello
      + # }
      + # world {
      + # }
      """

  Scenario: Invoke a recipe that sets xtrace and then invokes another recipe
    Given the Bashfile
      ```bash
      hello-world-xtrace() {
        echo "-----"

        set -x

        echo "Hello"
        bx::invoke world
        echo "-----"
      }

      world() {
        echo "World!"

        set +x
      }
      ```
    When invoking
      | RECIPE             |
      | hello-world-xtrace |
    Then bx outputs to stdout
      """
      -----
      Hello
      World!
      -----
      """
    And bx traces
      """
      + # hello-world-xtrace {
      ++ echo Hello
      ++ bx::invoke world
      ++ # world {
      ++ # }
      ++ echo -----
      + # }
      """

  Scenario: Invoke a recipe that alters shell options
    Given the shell environment
      ```bash
      shopt -u shift_verbose
      ```
    And the Bashfile
      ```bash
      recipe() {
        shopt -s shift_verbose
        set -x +o pipefail

        shopt shift_verbose || true
        shopt -o xtrace || true
        shopt -o pipefail || true
      }

      print-options() {
        echo "-----"
        shopt shift_verbose || true
        shopt -o xtrace || true
        shopt -o pipefail || true
      }
      ```
    When invoking
      | RECIPE        |
      | recipe        |
      | print-options |
    Then bx outputs to stdout
      """
      shift_verbose  	on
      xtrace         	on
      pipefail       	off
      -----
      shift_verbose  	off
      xtrace         	off
      pipefail       	on
      """
    And bx traces
      """
      + # recipe {
      ++ shopt shift_verbose
      ++ shopt -o xtrace
      ++ shopt -o pipefail
      ++ true
      + # }
      + # print-options {
      + # }
      """
    And bx does not error out
    And bx succeeds
