# frozen_string_literal: true

Given('the environment') do |env|
  shell.env = env
end

Given('the current working directory {string}') do |path|
  FileUtils.mkdir_p(path)
  Dir.chdir(path)
end
