Feature: CLI--Quiet

  Scenario Outline: Invoke a recipe in quiet mode
    Given the Bakefile
      ```bash
      recipe() {
        echo "Recipe was executed!!!"
      }
      ```
    When executing Bake with "<QUIET OPTION> recipe"
    Then Bake displays
      """
      Recipe was executed!!!
      """
    And Bake traces nothing
    And Bake does not error out

    Examples:
      | QUIET OPTION |
      | -q           |
      | --quiet      |

  Scenario: Invoke a recipe in quiet mode when xtrace is enabled
    Given the Bakefile
      ```bash
      recipe() {
        set -x

        echo "Recipe was executed!!!"
      }
      ```
    When executing Bake with "-q recipe"
    Then Bake displays
      """
      Recipe was executed!!!
      """
    And Bake traces nothing
    And Bake does not error out
