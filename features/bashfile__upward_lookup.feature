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
    When invoking
      | RECIPE         |
      | which-bashfile |
    Then recipes output
      | STDOUT          |
      | Parent Bashfile |
    And bx succeeds
