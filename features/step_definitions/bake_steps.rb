# frozen_string_literal: true

When('executing bx with {string}') do |arguments|
  # TODO: execute "bx" when bin/bake is renamed.
  shell.execute("bake #{arguments}")
end

When('executing bx with no arguments') do
  shell.execute('bake')
end

Then('bx displays nothing') do
  assert_equal('', shell.stdout, data_type: 'stdout')
end

Then('bx displays') do |stdout_content|
  assert_equal(stdout_content, shell.stdout, data_type: 'stdout')
end

Then('bx traces nothing') do
  assert_equal('', shell.xtrace, data_type: 'xtrace')
end

Then('bx traces') do |trace_content|
  assert_equal(trace_content, shell.xtrace, data_type: 'xtrace')
end

Then('bx warns with message {string}') do |warning|
  assert_equal(warning, shell.stderr, data_type: 'warning')
  assert_equal(0, shell.status, data_type: 'status')
end

Then('bx does not error out') do
  assert_equal('', shell.stderr, data_type: 'stderr')
  assert_equal(0, shell.status, data_type: 'status')
end

Then('bx errors out with message {string}') do |stderr_content|
  if stderr_content.empty?
    step('bx does not error out')
  else
    assert_equal(stderr_content, shell.stderr, data_type: 'stderr')
    assert_equal(1, shell.status, data_type: 'status')
  end
end
