Feature: Recipe Requirement--Arguments

  Scenario: Run `bake` for a recipe that requires another one with arguments
    Given the Bakefile
      ```bash
      pre-recipe() {
        echo "\$#=$#, \$1=$1, \$2=$2"
      }

      recipe-with-requirement() {
        @require: 'pre-recipe arg-1 arg-2'
        echo "\$#=$#"
      }
      ```
    When running `bake` with arguments "recipe-with-requirement"
    Then `bake` displays
      """
      pre-recipe arg-1 arg-2
      $#=2, $1=arg-1, $2=arg-2
      recipe-with-requirement
      $#=0
      """
    And `bake` does not error out

  Scenario Outline: Run `bake` for a recipe that requires one of multiple recipes with arguments
    Given the Bakefile
      ```bash
      pre-recipe-1() {
        echo "\$#=$#"
      }

      pre-recipe-2() {
        echo "\$#=$#, \$1=$1, \$2=$2"
      }

      pre-recipe-3() {
        echo "\$#=$#"
      }

      recipe-with-requirements() {
        @require: pre-recipe-1
        @require: 'pre-recipe-2 arg-1 arg-2'
        @require: pre-recipe-3
        echo "\$#=$#"
      }

      recipe-with-inline-requirements() {
        @require: pre-recipe-1 'pre-recipe-2 arg-1 arg-2' pre-recipe-3
        echo "\$#=$#"
      }
      ```
    When running `bake` with arguments "<RECIPE ARGUMENT>"
    Then `bake` displays
      """
      pre-recipe-1
      $#=0
      pre-recipe-2 arg-1 arg-2
      $#=2, $1=arg-1, $2=arg-2
      pre-recipe-3
      $#=0
      <RECIPE ARGUMENT>
      $#=0
      """
    And `bake` does not error out

    Examples:
      | RECIPE ARGUMENT                 |
      | recipe-with-requirements        |
      | recipe-with-inline-requirements |
