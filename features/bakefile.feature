Feature: Bakefile

  A Bakefile is the configuration file used by `bake`. Everything in a Bakefile
  is valid Bash 3.2+ code where functions are treated as recipes. Running
  `bake <recipe-name>` invokes the corresponding function.

  Scenario Outline: Run `bake` with the default Bakefile
    Given the Bakefile at "Bakefile"
      ```bash
      which-bakefile() {
        echo "default"
      }
      ```
    When running `bake` with arguments "<BAKEFILE ARGUMENT> which-bakefile"
    Then `bake` displays
      """
      which-bakefile
      default
      """
    And `bake` does not error out

    Examples:
      | BAKEFILE ARGUMENT |
      |                   |
      | -f Bakefile       |

  Scenario Outline: Run `bake` with a specific Bakefile
    Given the Bakefile at "Bakefile"
      ```bash
      which-bakefile() {
        echo "Bakefile"
      }
      ```
    And the Bakefile at "alternative.bakefile"
      ```bash
      which-bakefile() {
        echo "alternative.bakefile"
      }
      ```
    And the Bakefile at "another_alternative.bakefile"
      ```bash
      which-bakefile() {
        echo "another_alternative.bakefile"
      }
      ```
    When running `bake` with arguments "<BAKEFILE ARGUMENT> which-bakefile"
    Then `bake` displays
      """
      which-bakefile
      <EXECUTED BAKEFILE>
      """
    Then `bake` does not error out

    Examples:
      | BAKEFILE ARGUMENT                       | EXECUTED BAKEFILE            |
      |                                         | Bakefile                     |
      | -f Bakefile                             | Bakefile                     |
      | --file alternative.bakefile             | alternative.bakefile         |
      | --bakefile another_alternative.bakefile | another_alternative.bakefile |

  @fixme
  Scenario: Run `bake` without a Bakefile
    Given no Bakefile
    When running `bake` with arguments "some-recipe"
    Then `bake` displays nothing
    # TODO: This is not a good error message for this situation
    And `bake` errors out with message "bake: No recipes!"
