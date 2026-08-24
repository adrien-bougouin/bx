Feature: Bashfile

  A Bashfile is the configuration file used by bx. Everything in a Bashfile is
  valid Bash 3.2+ code where functions are treated as recipes. Executing
  `bx <recipe-name>` invokes the corresponding function.

  Scenario: Invoke a recipe from the default Bashfile
    Given the Bashfile at "Bashfile"
      ```bash
      which-bashfile() {
        echo "default"
      }
      ```
    When executing bx with "which-bashfile"
    Then bx displays
      """
      default
      """
    And bx does not error out

  Scenario Outline: Invoke a recipe from a specific Bashfile
    Given the Bashfile at "Bashfile"
      ```bash
      which-bashfile() {
        echo "Bashfile"
      }
      ```
    And the Bashfile at "alternative.bashfile"
      ```bash
      which-bashfile() {
        echo "alternative.bashfile"
      }
      ```
    And the Bashfile at "another_alternative.bashfile"
      ```bash
      which-bashfile() {
        echo "another_alternative.bashfile"
      }
      ```
    When executing bx with "<BASHFILE ARGUMENT> which-bashfile"
    Then bx displays
      """
      <LOADED BASHFILE>
      """
    And bx does not error out

    Examples:
      | BASHFILE ARGUMENT                       | LOADED BASHFILE              |
      | -f Bashfile                             | Bashfile                     |
      | --file alternative.bashfile             | alternative.bashfile         |
      | --file=alternative.bashfile             | alternative.bashfile         |
      | --bashfile another_alternative.bashfile | another_alternative.bashfile |
      | --bashfile=another_alternative.bashfile | another_alternative.bashfile |

  Scenario Outline: Invoke a recipe from multiple Bashfile
    Given the Bashfile at "Bashfile"
      ```bash
      which-bashfile() {
        echo "Bashfile"
      }
      ```
    And the Bashfile at "alternative.bashfile"
      ```bash
      which-bashfile() {
        echo "alternative.bashfile"
      }
      ```
    When executing bx with "<BASHFILE ARGUMENTS> which-bashfile"
    Then bx displays nothing
    And bx errors out with message "<ERROR>"

    Examples:
      | BASHFILE ARGUMENTS                  | ERROR                   |
      | -f Bashfile -f alternative.bashfile | bx: Too many Bashfiles! |
      | -f alternative.bashfile -f Bashfile | bx: Too many Bashfiles! |

  Scenario: Invoke a recipe without a Bashfile
    Given no Bashfile
    When executing bx with "some-recipe"
    Then bx displays nothing
    And bx errors out with message "bx: No Bashfile!"
