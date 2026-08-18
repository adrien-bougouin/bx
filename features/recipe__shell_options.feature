Feature: Recipe--Shell Options

  A recipe can change the shell options locally. The shell option changes do not
  affect Bake or other recipes.

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
      Hello
      World!
      """
    And Bake traces
      """
      + # hello-xtrace {
      ++ echo Hello
      + # }
      + # world {
      + # }
      """

  Scenario: Invoke a recipe that changes a shell option and invokes another recipe
    Given the Bakefile
      ```bash
      hello-world-xtrace() {
        echo "-----"

        set -x

        echo "Hello"
        bake::invoke world
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
      -----
      Hello
      World!
      -----
      """
    And Bake traces
      """
      + # hello-world-xtrace {
      ++ echo Hello
      ++ bake::invoke world
      ++ # world {
      ++ # }
      ++ echo -----
      + # }
      """
