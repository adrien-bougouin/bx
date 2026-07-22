Feature: Default Recipe--Arguments

  A default recipe can be invoked with arguments, as does any other recipe. When
  assigning a recipe as default with arguments, the `@default` annotation can't
  be used. The function `bake::recipes::set_default` must be used to assign a
  recipe to default with argument.

  Scenario Outline: Execute Bake when the default recipe has arguments
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
    When executing Bake with arguments "<RECIPE ARGUMENT>"
    Then Bake displays
      """
      <INVOKED RECIPE>
      <RECIPE OUTPUT>
      """
    And Bake does not error out

    Examples:
      | RECIPE ARGUMENT    | INVOKED RECIPE             | RECIPE OUTPUT            |
      |                    | default-recipe arg-1 arg-2 | $#=2, $1=arg-1, $2=arg-2 |
      | non-default-recipe | non-default-recipe         | $#=0                     |

  Scenario Outline: Execute Bake when one of too many default recipes has arguments
    Given the Bakefile
      ```bash
      bake::recipes::set_default "default-recipe-1 arg-1 arg-2" "default-recipe-2"

      default-recipe-1() { :; }

      default-recipe-2() { :; }
      ```
    When executing Bake with arguments "<RECIPE ARGUMENT>"
    Then Bake displays nothing
    And Bake errors out with message "<ERROR>"

    Examples:
      | RECIPE ARGUMENT                | ERROR                           |
      |                                | bake: Too many default recipes! |
      | default-recipe-1               | bake: Too many default recipes! |
      | default-recipe-2               | bake: Too many default recipes! |
      | 'default-recipe-1 arg-1 arg-2' | bake: Too many default recipes! |
      | 'default-recipe-2 arg-1 arg-2' | bake: Too many default recipes! |
