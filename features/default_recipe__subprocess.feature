Feature: Default Recipe--Subprocess

  Scenario: Run `bake` when the default recipe is a subprocess
    Given the Bakefile
      ```bash
      non-default-recipe() ( :; )

      default-recipe() ( @default; )
      ```
    When running `bake` with no arguments
    Then `bake` displays
      """
      default-recipe
      """
    And `bake` does not error out
