# frozen_string_literal: true

require 'shellwords'

# When #########################################################################

When('setting options') do |options|
  bx.options.concat(options.raw.flatten)
end

When('invoking') do |*args|
  table = args.first

  bx_arguments = []
  bx_stdin_data = nil

  if table
    raise('Invalid invocation table!') unless table.headers.include?('RECIPE')

    invocation_list = table.hashes

    confirmations = invocation_list.map do |row|
      row['CONFIRMATION'] || ''
    end.reject(&:empty?)

    bx_arguments = invocation_list.map { |r| r['RECIPE'] }.reject(&:empty?)
    bx_stdin_data = confirmations.join unless confirmations.empty?
  end

  bx.call(arguments: bx_arguments, stdin_data: bx_stdin_data)
end

# Then #########################################################################

Then('bx displays nothing') do
  assert_equal('', bx.stdout)
end

Then('bx displays') do |stdout_content|
  assert_equal(stdout_content, bx.stdout)
end

Then('bx confirms nothing') do
  assert_equal('', bx.confirmations)
end

Then('bx confirms') do |table|
  raise('Invalid confirmation table!') unless table.headers.include?('RECIPE')

  expected_confirmations = table.hashes.map do |row|
    build_confirmation_string(row['RECIPE'])
  end

  assert_equal(expected_confirmations.join("\n"), bx.confirmations)
end

Then('bx traces nothing') do
  assert_equal('', bx.xtrace)
end

Then('bx traces') do |trace_content|
  assert_equal(trace_content, bx.xtrace)
end

Then('bx warns with message {string}') do |warning|
  assert_equal(warning, bx.stderr)
end

Then('bx does not error out') do
  assert_equal('', bx.stderr)
end

Then('bx errors out with message {string}') do |stderr_content|
  if stderr_content.empty?
    step('bx does not error out')
  else
    assert_equal(stderr_content, bx.stderr)
  end
end

Then(
  'bx errors out with message containing {string}'
) do |partial_stderr_content|
  assert_match(partial_stderr_content, bx.stderr)
end

Then('bx succeeds') do
  assert_equal(0, bx.status)
end

Then('bx fails') do
  assert_not_equal(0, bx.status)
end

# Helpers ######################################################################

def build_confirmation_string(recipe_invocation)
  canonical_recipe_invocation = canonicalize_recipe_invocation(
    recipe_invocation
  )

  "bx: Invoke recipe `#{canonical_recipe_invocation}`? [y/N]"
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

  escaped_script = Shellwords.escape(script)
  escaped_recipe_invocation = Shellwords.escape(recipe_invocation)

  `bash -c #{escaped_script} bx #{escaped_recipe_invocation}`.chomp
end
