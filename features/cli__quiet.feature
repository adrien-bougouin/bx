Feature: CLI--Quiet

  Scenario Outline: Invoke a recipe in quiet mode
    Given the Bashfile
      ```bash
      recipe() {
        echo "Recipe was invoked!!!"
      }
      ```
    When executing bx with "<QUIET OPTION> recipe"
    Then bx displays
      """
      Recipe was invoked!!!
      """
    And bx traces nothing
    And bx does not error out

    Examples:
      | QUIET OPTION |
      | -q           |
      | --quiet      |

  Scenario: Invoke a recipe in quiet mode when xtrace is enabled
    Given the Bashfile
      ```bash
      recipe() {
        set -x

        echo "Recipe was invoked!!!"
      }
      ```
    When executing bx with "-q recipe"
    Then bx displays
      """
      Recipe was invoked!!!
      """
    And bx traces nothing
    And bx does not error out
