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
    When invoking
      | RECIPE         |
      | which-bashfile |
    Then bx outputs to stdout
      """
      default
      """
    And bx does not error out
    And bx succeeds

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
    When setting
      | OPTION              |
      | <BASHFILE ARGUMENT> |
    And invoking
      | RECIPE         |
      | which-bashfile |
    Then bx outputs to stdout
      """
      <LOADED BASHFILE>
      """
    And bx does not error out
    And bx succeeds

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
    When setting
      | OPTION               |
      | <BASHFILE ARGUMENTS> |
    And invoking
      | RECIPE         |
      | which-bashfile |
    Then bx outputs nothing to stdout
    And bx errors out with message "<ERROR>"
    And bx fails

    Examples:
      | BASHFILE ARGUMENTS                  | ERROR                   |
      | -f Bashfile -f alternative.bashfile | bx: Too many Bashfiles! |
      | -f alternative.bashfile -f Bashfile | bx: Too many Bashfiles! |

  Scenario: Invoke a recipe without a Bashfile
    Given no Bashfile
    When invoking
      | RECIPE      |
      | some-recipe |
    Then bx outputs nothing to stdout
    And bx errors out with message "bx: No Bashfile!"
    And bx fails
