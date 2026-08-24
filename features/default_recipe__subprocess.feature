Feature: Default Recipe--Subprocess

  Scenario: Invoke when the default recipe is a subprocess
    Given the Bashfile
      ```bash
      non-default-recipe() ( :; )

      default-recipe() ( @default; )
      ```
    When executing bx with no arguments
    Then bx traces
      """
      + # default-recipe {
      + # }
      """
    And bx does not error out
