Feature: Bashfile

  A Bashfile is the configuration file used by bx. Everything in a Bashfile is
  valid Bash 3.2+ code where functions are treated as recipes. Executing
  `bx <recipe-name>` invokes the corresponding function.

  Scenario: Invoke a recipe from the default Bashfile
    Given the Bashfile at "Bakefile"
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
    Given the Bashfile at "Bakefile"
      ```bash
      which-bashfile() {
        echo "Bakefile"
      }
      ```
    And the Bashfile at "alternative.bakefile"
      ```bash
      which-bashfile() {
        echo "alternative.bakefile"
      }
      ```
    And the Bashfile at "another_alternative.bakefile"
      ```bash
      which-bashfile() {
        echo "another_alternative.bakefile"
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
      | -f Bakefile                             | Bakefile                     |
      | --file alternative.bakefile             | alternative.bakefile         |
      | --file=alternative.bakefile             | alternative.bakefile         |
      | --bashfile another_alternative.bakefile | another_alternative.bakefile |
      | --bashfile=another_alternative.bakefile | another_alternative.bakefile |

  Scenario Outline: Invoke a recipe from multiple Bashfile
    Given the Bashfile at "Bakefile"
      ```bash
      which-bashfile() {
        echo "Bakefile"
      }
      ```
    And the Bashfile at "alternative.bakefile"
      ```bash
      which-bashfile() {
        echo "alternative.bakefile"
      }
      ```
    When executing bx with "<BASHFILE ARGUMENTS> which-bashfile"
    Then bx displays nothing
    And bx errors out with message "<ERROR>"

    Examples:
      | BASHFILE ARGUMENTS                  | ERROR                   |
      | -f Bakefile -f alternative.bakefile | bx: Too many Bashfiles! |
      | -f alternative.bakefile -f Bakefile | bx: Too many Bashfiles! |

  Scenario: Invoke a recipe without a Bashfile
    Given no Bashfile
    When executing bx with "some-recipe"
    Then bx displays nothing
    And bx errors out with message "bx: No Bashfile!"
