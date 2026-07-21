Feature: Recipe Requirement--Subprocess

  Scenario: Execute Bake for a subprocess recipe that requires another one
    Given the Bakefile
      ```bash
      pre-recipe() ( :; )

      recipe-with-requirement() ( @require: pre-recipe; )
      ```
    When executing Bake with arguments "recipe-with-requirement"
    Then Bake displays
      """
      pre-recipe
      recipe-with-requirement
      """
    And Bake does not error out
