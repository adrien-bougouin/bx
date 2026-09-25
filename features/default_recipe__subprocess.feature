Feature: Default Recipe--Subprocess

  Scenario: Invoke when the default recipe is a subprocess
    Given the Bashfile
      ```bash
      non-default-recipe() ( :; )

      default-recipe() ( @default; )
      ```
    When invoking
    Then bx outputs to stderr
      | FORMAT       | CONTENT        |
      | bx-trace-in  | default-recipe |
      | bx-trace-out |                |
    And bx succeeds
