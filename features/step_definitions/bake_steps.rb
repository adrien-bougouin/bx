# frozen_string_literal: true

When('running `bake` with arguments {string}') do |args|
  shell.execute("bake #{args}")
end

When('running `bake` with no arguments') do
  step("running `bake` with arguments ''")
end

Then('bake displays nothing') do
  assert_equal('', shell.stdout, data_type: 'stdout')
end

Then('bake displays') do |stdout_content|
  assert_equal(stdout_content, shell.stdout, data_type: 'stdout')
end

Then('bake does not error out') do
  assert_equal('', shell.stderr, data_type: 'stderr')
  assert_equal(0, shell.status, data_type: 'status')
end

Then('bake errors out with message {string}') do |stderr_content|
  if stderr_content.empty?
    step('bake does not error out')
  else
    assert_equal(stderr_content, shell.stderr, data_type: 'stderr')
    assert_equal(1, shell.status, data_type: 'status')
  end
end
