Feature: Bashfile--Upward Lookup

  bx looks for the nearest default Bashfile, walking up the directories.

  Scenario: Invoke a recipe with Bashfile lookup
    Given the Bashfile
      ```bash
      which-bashfile() {
        echo "Parent Bashfile"
      }
      ```
    And the current working directory "./deeply/nested/working/directory"
    When setting
      | OPTION |
      | -q     |
    And invoking
      | RECIPE         |
      | which-bashfile |
    Then bx outputs
      | DATA            |
      | Parent Bashfile |
    And bx succeeds
