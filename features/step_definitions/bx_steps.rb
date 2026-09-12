# frozen_string_literal: true

Given('the environment') do |env|
  self.env << env
end

# New steps proposal ###########################################################

# When using options
#   | --quiet |
#   | --yes   |
#
# When invoking
#   | recipe               |
#   | 'recipe with 3 args' |
#
# When invoking
#   | recipe               |         |
#   | 'recipe with 3 args' |         |
#   | recipe-with-conf     | CONFIRM |
#   | recipe-with-conf     | REJECT  |

################################################################################

# TODO: Remove in favor of "When invoking..." or
#       "When using options... And invoking..."
When('executing bx with {string}') do |arguments|
  bx.call(arguments:)
end

# TODO: Remove in favor of last table CONFIRM/REJECT during "When invoking..."
#       or "When using options... And invoking..."
When('executing bx with {string} and confirmation sequence') do |arguments, confirmations|
  bx.call(arguments:, stdin_data: confirmations.raw.join)
end

# TODO: Remove in favor of When('invoking') with no table
When('executing bx with no arguments') do
  bx.call
end

Then('bx displays nothing') do
  assert_equal('', bx.stdout, data_type: 'stdout')
end

Then('bx displays') do |stdout_content|
  assert_equal(stdout_content, bx.stdout, data_type: 'stdout')
end

Then('bx confirms') do |confirmations|
  assert_equal(confirmations.raw.join("\n"), bx.confirmations, data_type: 'confirmation')
end

Then('bx confirms nothing') do
  assert_equal('', bx.confirmations, data_type: 'confirmation')
end

Then('bx traces nothing') do
  assert_equal('', bx.xtrace, data_type: 'xtrace')
end

Then('bx traces') do |trace_content|
  assert_equal(trace_content, bx.xtrace, data_type: 'xtrace')
end

Then('bx warns with message {string}') do |warning|
  assert_equal(warning, bx.stderr, data_type: 'warning')
  assert_equal(0, bx.status, data_type: 'status')
end

Then('bx does not error out') do
  assert_equal('', bx.stderr, data_type: 'stderr')
  assert_equal(0, bx.status, data_type: 'status')
end

Then('bx errors out with message {string}') do |stderr_content|
  if stderr_content.empty?
    step('bx does not error out')
  else
    assert_equal(stderr_content, bx.stderr, data_type: 'stderr')
    assert_equal(1, bx.status, data_type: 'status')
  end
end
