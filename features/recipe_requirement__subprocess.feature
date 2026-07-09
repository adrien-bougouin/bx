Feature: Recipe Requirement--Subprocess

  Scenario: Run `bake` for a subprocess recipe that requires another one
    Given the Bakefile
      ```bash
      pre-recipe() ( :; )

      recipe-with-requirement() ( @require: pre-recipe; )
      ```
    When running `bake` with arguments "recipe-with-requirement"
    Then bake displays
      """
      pre-recipe
      recipe-with-requirement
      """
    And bake does not error out
