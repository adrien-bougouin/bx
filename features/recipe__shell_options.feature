Feature: Recipe--Shell Options

  A recipe can change the shell options locally. The shell option changes won't
  impact bake or other recipes.

  Scenario: Invoke multiple recipes when one changes a shell option
    Given the Bakefile
      ```bash
      hello-xtrace() {
        set -x

        echo "Hello"
      }

      world() {
        echo "World!"
      }
      ```
    When executing Bake with "hello-xtrace world"
    Then Bake displays
      """
      hello-xtrace
      Hello
      world
      World!
      """
    And Bake traces
      """
      ++ echo Hello
      """

  Scenario: Invoke a recipes that changes a shell option and invoke another recipe
    Given the Bakefile
      ```bash
      hello-world-xtrace() {
        echo "-----"

        set -x

        echo "Hello"
        bake::recipes::invoke world
        echo "-----"
      }

      world() {
        echo "World!"

        set +x
      }
      ```
    When executing Bake with "hello-world-xtrace"
    Then Bake displays
      """
      hello-world-xtrace
      -----
      Hello
      world
      World!
      -----
      """
    And Bake traces
      """
      ++ echo Hello
      ++ bake::recipes::invoke world
      ++ echo -----
      """
