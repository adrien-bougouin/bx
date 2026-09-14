# frozen_string_literal: true

When('setting options') do |options|
  bx.options.concat(options.raw.flatten)
end

When('invoking') do |*args|
  invocations = args.first&.raw

  bx_arguments = ''
  bx_stdin_data = nil

  input = lambda do |confirm_sequence|
    bx_stdin_data ||= ''
    bx_stdin_data += confirm_sequence
  end

  if invocations
    bx_arguments = invocations.map(&:first).reject(&:empty?).join(' ')

    invocations.each do |invocation|
      confirmation_sequence = invocation[1] || []
      next if confirmation_sequence.empty?

      eval(confirmation_sequence.gsub('input(', 'input.('), binding) # rubocop:disable Security/Eval
    end
  end

  bx.call(arguments: bx_arguments, stdin_data: bx_stdin_data)
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
    assert_not_equal(0, bx.status, data_type: 'status')
  end
end

Then('bx errors out with message containing {string}') do |partial_stderr_content|
  assert_include(partial_stderr_content, bx.stderr, data_type: 'stderr')
  assert_not_equal(0, bx.status, data_type: 'status')
end
