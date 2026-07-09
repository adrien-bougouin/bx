# frozen_string_literal: true

CUCUMBER_WORKSPACES = './features/.cucumber'

Before do |scenario|
  normalized_scenario_name = scenario.name.downcase.gsub(/[^a-z0-9]+/, '-')

  @original_working_directory = Dir.pwd
  @workspace = File.join(CUCUMBER_WORKSPACES, "scenario-#{normalized_scenario_name}")

  FileUtils.rm_rf(@workspace)
  FileUtils.mkdir_p(@workspace)

  Dir.chdir(@workspace)
end

After do |scenario|
  Dir.chdir(@original_working_directory)

  FileUtils.rm_rf(@workspace) unless scenario.failed?
  FileUtils.rm_rf(CUCUMBER_WORKSPACES) if Dir.empty?(CUCUMBER_WORKSPACES)
end
