Feature: Bakefile

  A Bakefile is the configuration file used by Bake. Everything in a Bakefile is
  valid Bash 3.2+ code where functions are treated as recipes. Executing
  `bake <recipe-name>` invokes the corresponding function.

  Scenario Outline: Execute Bake with the default Bakefile
    Given the Bakefile at "Bakefile"
      ```bash
      which-bakefile() {
        echo "default"
      }
      ```
    When executing Bake with arguments "<BAKEFILE ARGUMENT> which-bakefile"
    Then Bake displays
      """
      which-bakefile
      default
      """
    And Bake does not error out

    Examples:
      | BAKEFILE ARGUMENT |
      |                   |
      | -f Bakefile       |

  Scenario Outline: Execute Bake with a specific Bakefile
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
    When executing Bake with arguments "<BAKEFILE ARGUMENT> which-bakefile"
    Then Bake displays
      """
      which-bakefile
      <LOADED BAKEFILE>
      """
    Then Bake does not error out

    Examples:
      | BAKEFILE ARGUMENT                       | LOADED BAKEFILE              |
      |                                         | Bakefile                     |
      | -f Bakefile                             | Bakefile                     |
      | --file alternative.bakefile             | alternative.bakefile         |
      | --bakefile another_alternative.bakefile | another_alternative.bakefile |

  @fixme
  Scenario: Execute Bake without a Bakefile
    Given no Bakefile
    When executing Bake with arguments "some-recipe"
    Then Bake displays nothing
    # TODO: This is not a good error message for this situation
    And Bake errors out with message "bake: No recipes!"
