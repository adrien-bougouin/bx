Feature: Recipe Requirement--Arguments

  Scenario: Invoke a recipe that requires another one with arguments
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
    When executing Bake with arguments "recipe-with-requirement"
    Then Bake displays
      """
      pre-recipe arg-1 arg-2
      $#=2, $1=arg-1, $2=arg-2
      recipe-with-requirement
      $#=0
      """
    And Bake does not error out

  Scenario Outline: Invoke a recipe that requires multiple recipes, one with arguments
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
    When executing Bake with arguments "<RECIPE ARGUMENT>"
    Then Bake displays
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
    And Bake does not error out

    Examples:
      | RECIPE ARGUMENT                 |
      | recipe-with-requirements        |
      | recipe-with-inline-requirements |
