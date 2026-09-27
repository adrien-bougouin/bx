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
    And bx outputs to stderr
      | FORMAT       | CONTENT      |
      | bx-trace-in  | hello-xtrace |
      | xtrace       | echo Hello   |
      | bx-trace-out |              |
      | bx-trace-in  | world        |
      | bx-trace-out |              |
    And bx succeeds

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
    And bx outputs to stderr
      | FORMAT       | CONTENT            |
      | bx-trace-in  | hello-world-xtrace |
      | xtrace       | echo Hello         |
      | xtrace       | bx::invoke world   |
      | bx-trace-in  | world              |
      | bx-trace-out |                    |
      | xtrace       | echo -----         |
      | bx-trace-out |                    |
    And bx succeeds

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
    And bx outputs to stderr
      | FORMAT       | CONTENT             |
      | bx-trace-in  | recipe              |
      | xtrace       | shopt shift_verbose |
      | xtrace       | shopt -o xtrace     |
      | xtrace       | shopt -o pipefail   |
      | xtrace       | true                |
      | bx-trace-out |                     |
      | bx-trace-in  | print-options       |
      | bx-trace-out |                     |
    And bx succeeds
