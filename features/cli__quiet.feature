Feature: CLI--Quiet

  Scenario Outline: Run `bake` in quiet mode
    Given the Bakefile
      ```bash
      recipe() {
        echo "Recipe was executed!!!"
      }
      ```
    When running `bake` with arguments "<QUIET OPTION> recipe"
    Then `bake` displays
      """
      Recipe was executed!!!
      """
    And `bake` does not error out

    Examples:
      | QUIET OPTION |
      | -s           |
      | --silent     |
      | -q           |
      | --quiet      |
