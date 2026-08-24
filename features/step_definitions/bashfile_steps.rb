# frozen_string_literal: true

Given('no Bashfile') do
  ['Bashfile', '*.bashfile'].each do |pattern|
    FileUtils.rm(pattern)
  rescue Errno::ENOENT # rubocop:disable Lint/SuppressedException
  end
end

Given('the Bashfile') do |bashfile_content|
  File.write('Bashfile', bashfile_content)
end

Given('an empty Bashfile') do
  File.write('Bashfile', '')
end

Given('the Bashfile at {string}') do |bashfile_name, bashfile_content|
  File.write(bashfile_name, bashfile_content)
end
