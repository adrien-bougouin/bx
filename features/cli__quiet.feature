Feature: CLI--Quiet

  Scenario Outline: Execute Bake in quiet mode
    Given the Bakefile
      ```bash
      recipe() {
        echo "Recipe was executed!!!"
      }
      ```
    When executing Bake with arguments "<QUIET OPTION> recipe"
    Then Bake displays
      """
      Recipe was executed!!!
      """
    And Bake does not error out

    Examples:
      | QUIET OPTION |
      | -s           |
      | --silent     |
      | -q           |
      | --quiet      |
