Feature: Bakefile--Upward Lookup

  Bake looks for the nearest default Bakefile, walking up the directories.

  Scenario: Invoke a recipe with Bakefile lookup
    Given the Bakefile
      ```bash
      which-bakefile() {
        echo "Parent Bakefile"
      }
      ```
    And the current working directory "./deeply/nested/working/directory"
    When executing Bake with "which-bakefile"
    Then Bake displays
      """
      Parent Bakefile
      """
    And Bake does not error out
