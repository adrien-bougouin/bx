# frozen_string_literal: true

Given('no Bakefile') do
  ['Bakefile', '*.bakefile'].each do |pattern|
    FileUtils.rm(pattern)
  rescue Errno::ENOENT # rubocop:disable Lint/SuppressedException
  end
end

Given('the Bakefile') do |bakefile_content|
  File.write('Bakefile', bakefile_content)
end

Given('the Bakefile at {string}') do |bakefile_name, bakefile_content|
  File.write(bakefile_name, bakefile_content)
end
