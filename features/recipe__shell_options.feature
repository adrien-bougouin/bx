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
    Then bx outputs
      | TYPE   | DATA         |
      | bx-in  | hello-xtrace |
      | xtrace | echo Hello   |
      |        | Hello        |
      | bx-out |              |
      | bx-in  | world        |
      |        | World!       |
      | bx-out |              |
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
    Then bx outputs
      | TYPE   | DATA               |
      | bx-in  | hello-world-xtrace |
      |        | -----              |
      | xtrace | echo Hello         |
      |        | Hello              |
      | xtrace | bx::invoke world   |
      | bx-in  | world              |
      |        | World!             |
      | bx-out |                    |
      | xtrace | echo -----         |
      |        | -----              |
      | bx-out |                    |
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

        shopt | grep shift_verbose
        shopt -o | grep xtrace
        shopt -o | grep pipefail
      }

      print-options() {
        echo "-----"
        shopt | grep shift_verbose
        shopt -o | grep xtrace
        shopt -o | grep pipefail
      }
      ```
    When invoking
      | RECIPE        |
      | recipe        |
      | print-options |
    Then bx outputs
      | TYPE   | DATA                 |
      | bx-in  | recipe               |
      | xtrace | shopt                |
      | xtrace | grep shift_verbose   |
      |        | shift_verbose  	on  |
      | xtrace | shopt -o             |
      | xtrace | grep xtrace          |
      |        | xtrace         	on  |
      | xtrace | shopt -o             |
      | xtrace | grep pipefail        |
      |        | pipefail       	off |
      | bx-out |                      |
      | bx-in  | print-options        |
      |        | -----                |
      |        | shift_verbose  	off |
      |        | xtrace         	off |
      |        | pipefail       	on  |
      | bx-out |                      |
    And bx succeeds
