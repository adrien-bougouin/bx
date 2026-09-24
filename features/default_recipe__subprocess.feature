Feature: Default Recipe--Subprocess

  Scenario: Invoke when the default recipe is a subprocess
    Given the Bashfile
      ```bash
      non-default-recipe() ( :; )

      default-recipe() ( @default; )
      ```
    When invoking
    Then bx outputs
      | FORMAT | DATA           |
      | bx-in  | default-recipe |
      | bx-out |                |
    And bx succeeds
