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
    When executing bx with "hello-xtrace world"
    Then bx displays
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
    When executing bx with "hello-world-xtrace"
    Then bx displays
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
    Given the environment
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
    When executing bx with "recipe print-options"
    Then bx displays
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
      ++ shopt
      ++ grep shift_verbose
      ++ shopt -o
      ++ grep xtrace
      ++ shopt -o
      ++ grep pipefail
      + # }
      + # print-options {
      + # }
      """
