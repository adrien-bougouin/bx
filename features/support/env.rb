# frozen_string_literal: true

CUCUMBER_WORKSPACES = Dir.mktmpdir('cucumber_workspaces')

Cucumber.logger.info("Worspaces: #{CUCUMBER_WORKSPACES}\n\n")

Before do |scenario|
  normalized_scenario_name = scenario.name.downcase.gsub(/[^a-z0-9]+/, '-')

  @original_working_directory = Dir.pwd
  @workspace = File.join(CUCUMBER_WORKSPACES, "scenario-#{normalized_scenario_name}")

  FileUtils.mkdir_p(@workspace)
  Dir.chdir(@workspace)
end

After do |scenario|
  Dir.chdir(@original_working_directory)
  FileUtils.remove_entry(@workspace) unless scenario.failed?
  FileUtils.remove_entry(CUCUMBER_WORKSPACES) if Dir.empty?(CUCUMBER_WORKSPACES)
end
