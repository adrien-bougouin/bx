Feature: Default Recipe--Subprocess

  Scenario: Invoke when the default recipe is a subprocess
    Given the Bakefile
      ```bash
      non-default-recipe() ( :; )

      default-recipe() ( @default; )
      ```
    When executing Bake with no arguments
    Then Bake traces
      """
      + # default-recipe {
      + # }
      """
    And Bake does not error out
