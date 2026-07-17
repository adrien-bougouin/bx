Feature: Default Recipe--Arguments

  Scenario Outline: Run `bake` when the default recipe has arguments
    Given the Bakefile
      ```bash
      bake::recipes::set_default "default-recipe arg-1 arg-2"

      non-default-recipe() {
        echo "\$#=$#"
      }

      default-recipe() {
        echo "\$#=$#, \$1=$1, \$2=$2"
      }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays
      """
      <EXECUTED RECIPE>
      <RECIPE OUTPUT>
      """
    And `bake` does not error out

    Examples:
      | RECIPE ARGUMENT    | EXECUTED RECIPE            | RECIPE OUTPUT            |
      |                    | default-recipe arg-1 arg-2 | $#=2, $1=arg-1, $2=arg-2 |
      | non-default-recipe | non-default-recipe         | $#=0                     |

  Scenario Outline: Run `bake` when one of too many default recipes has arguments
    Given the Bakefile
      ```bash
      bake::recipes::set_default "default-recipe-1 arg-1 arg-2" "default-recipe-2"

      default-recipe-1() { :; }

      default-recipe-2() { :; }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays nothing
    And `bake` errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT                | ERROR                           |
      |                                | bake: Too many default recipes! |
      | default-recipe-1               | bake: Too many default recipes! |
      | default-recipe-2               | bake: Too many default recipes! |
      | 'default-recipe-1 arg-1 arg-2' | bake: Too many default recipes! |
      | 'default-recipe-2 arg-1 arg-2' | bake: Too many default recipes! |
