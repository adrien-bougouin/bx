# frozen_string_literal: true

When('executing Bake with {string}') do |arguments|
  shell.execute("bake #{arguments}")
end

When('executing Bake with no arguments') do
  shell.execute('bake')
end

Then('Bake displays nothing') do
  assert_equal('', shell.stdout, data_type: 'stdout')
end

Then('Bake displays') do |stdout_content|
  assert_equal(stdout_content, shell.stdout, data_type: 'stdout')
end

Then('Bake does not error out') do
  assert_equal('', shell.stderr, data_type: 'stderr')
  assert_equal(0, shell.status, data_type: 'status')
end

Then('Bake errors out with message {string}') do |stderr_content|
  if stderr_content.empty?
    step('Bake does not error out')
  else
    assert_equal(stderr_content, shell.stderr, data_type: 'stderr')
    assert_equal(1, shell.status, data_type: 'status')
  end
end
