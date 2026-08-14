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
    When executing Bake with "recipe-with-requirement"
    Then Bake displays
      """
      $#=2, $1=arg-1, $2=arg-2
      $#=0
      """
    And Bake traces
      """
      + # pre-recipe arg-1 arg-2 {
      + # }
      + # recipe-with-requirement {
      + # }
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
    When executing Bake with "<RECIPE ARGUMENT>"
    Then Bake displays
      """
      $#=0
      $#=2, $1=arg-1, $2=arg-2
      $#=0
      $#=0
      """
    And Bake traces
      """
      + # pre-recipe-1 {
      + # }
      + # pre-recipe-2 arg-1 arg-2 {
      + # }
      + # pre-recipe-3 {
      + # }
      + # <RECIPE ARGUMENT> {
      + # }
      """
    And Bake does not error out

    Examples:
      | RECIPE ARGUMENT                 |
      | recipe-with-requirements        |
      | recipe-with-inline-requirements |
