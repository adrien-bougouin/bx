Feature: Recipe--Shell Options

  A recipe can change the shell options locally. The shell option changes do not
  affect bx or other recipes.

  Scenario: Invoke multiple recipes when one changes a shell option
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

  Scenario: Invoke a recipe that changes a shell option and invokes another recipe
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
