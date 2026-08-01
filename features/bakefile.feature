Feature: Bakefile

  A Bakefile is the configuration file used by Bake. Everything in a Bakefile is
  valid Bash 3.2+ code where functions are treated as recipes. Executing
  `bake <recipe-name>` invokes the corresponding function.

  Scenario: Invoke a recipe from the default Bakefile
    Given the Bakefile at "Bakefile"
      ```bash
      which-bakefile() {
        echo "default"
      }
      ```
    When executing Bake with "which-bakefile"
    Then Bake displays
      """
      + which-bakefile
      default
      """
    And Bake does not error out

  Scenario Outline: Invoke a recipe from a specific Bakefile
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
    When executing Bake with "<BAKEFILE ARGUMENT> which-bakefile"
    Then Bake displays
      """
      + which-bakefile
      <LOADED BAKEFILE>
      """
    And Bake does not error out

    Examples:
      | BAKEFILE ARGUMENT                       | LOADED BAKEFILE              |
      | -f Bakefile                             | Bakefile                     |
      | --file alternative.bakefile             | alternative.bakefile         |
      | --bakefile another_alternative.bakefile | another_alternative.bakefile |

  Scenario Outline: Invoke a recipe from multiple Bakefile
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
    When executing Bake with "<BAKEFILE ARGUMENTS> which-bakefile"
    Then Bake displays nothing
    And Bake errors out with message "<ERROR>"

    Examples:
      | BAKEFILE ARGUMENTS                  | ERROR                     |
      | -f Bakefile -f alternative.bakefile | bake: Too many Bakefiles! |
      | -f alternative.bakefile -f Bakefile | bake: Too many Bakefiles! |

  Scenario: Invoke a recipe without a Bakefile
    Given no Bakefile
    When executing Bake with "some-recipe"
    Then Bake displays nothing
    And Bake errors out with message "bake: No Bakefile!"
