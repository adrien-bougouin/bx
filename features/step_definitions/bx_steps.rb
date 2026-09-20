# frozen_string_literal: true

require 'shellwords'

# When #########################################################################

When('setting options') do |options|
  bx.options.concat(options.raw.flatten)
end

When('invoking') do |*args|
  table = args.first

  bx_arguments = ''
  bx_stdin_data = nil

  if table
    raise('Invalid invocation table!') unless table.headers.include?('RECIPE')

    invocation_list = table.hashes

    recipes = invocation_list.map { |r| r['RECIPE'] }.reject(&:empty?)
    confirmations = invocation_list.map { |r| r['CONFIRMATION'] || '' }.reject(&:empty?)

    bx_arguments = recipes.map(&:inspect).join(' ')
    bx_stdin_data = confirmations.join unless confirmations.empty?
  end

  bx.call(arguments: bx_arguments, stdin_data: bx_stdin_data)
end

# Then #########################################################################

Then('bx displays nothing') do
  assert_equal('', bx.stdout, data_type: 'stdout')
end

Then('bx displays') do |stdout_content|
  assert_equal(stdout_content, bx.stdout, data_type: 'stdout')
end

Then('bx confirms nothing') do
  assert_equal('', bx.confirmations, data_type: 'confirmation')
end

Then('bx confirms') do |table|
  raise('Invalid confirmation table!') unless table.headers.include?('RECIPE')

  expected_confirmations = table.hashes.map do |row|
    build_confirmation_string(row['RECIPE'])
  end

  assert_equal(
    expected_confirmations.join("\n"),
    bx.confirmations,
    data_type: 'confirmation'
  )
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

# Helpers ######################################################################

def build_confirmation_string(recipe_invocation)
  "bx: Invoke recipe `#{canonicalize_recipe_invocation(recipe_invocation)}`? [y/N]"
end

def canonicalize_recipe_invocation(recipe_invocation)
  script = <<~BASH
    eval "words+=($1)"
    printf "%s" "${words[0]}"
    for word in "${words[@]:1}"; do
      printf -v q "%q" "$word"
      printf " '%s'" "$q"
    done
  BASH

  `bash -c #{Shellwords.escape(script)} bx #{Shellwords.escape(recipe_invocation)}`.chomp
end
