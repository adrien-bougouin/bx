# frozen_string_literal: true

When('executing bx with {string}') do |arguments|
  shell.execute("bx #{arguments}")
end

When('executing bx with {string} and confirmation sequence') do |arguments, confirmations|
  shell.execute("bx #{arguments}", stdin_data: confirmations.raw.join)
end

When('executing bx with no arguments') do
  shell.execute('bx')
end

Then('bx displays nothing') do
  assert_equal('', shell.stdout, data_type: 'stdout')
end

Then('bx displays') do |stdout_content|
  assert_equal(stdout_content, shell.stdout, data_type: 'stdout')
end

Then('bx confirms') do |confirmations|
  assert_equal(confirmations.raw.join("\n"), shell.confirmations, data_type: 'confirmation')
end

Then('bx confirms nothing') do
  assert_equal('', shell.confirmations, data_type: 'confirmation')
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
