Feature: Recipe Requirement--Subprocess

  Scenario: Invoke a subprocess recipe that requires another recipe
    Given the Bakefile
      ```bash
      pre-recipe() ( :; )

      recipe-with-requirement() ( @require: pre-recipe; )
      ```
    When executing Bake with "recipe-with-requirement"
    Then Bake traces
      """
      + # pre-recipe {
      + # }
      + # recipe-with-requirement {
      + # }
      """
    And Bake does not error out
