# frozen_string_literal: true

require 'shellwords'

# When #########################################################################

When('setting') do |table|
  raise('Invalid settings table!') unless table.headers.include?('OPTION')

  bx_options.concat(table.hashes.map { |r| r['OPTION'] })
end

When('invoking') do |*args|
  table = args.first

  arguments = []
  stdin_data = nil

  if table
    raise('Invalid invocation table!') unless table.headers.include?('RECIPE')

    invocation_list = table.hashes

    confirmations = invocation_list.map do |row|
      row['CONFIRMATION'] || ''
    end.reject(&:empty?)

    arguments = invocation_list.map { |r| r['RECIPE'] }.reject(&:empty?)
    stdin_data = confirmations.join unless confirmations.empty?
  end

  call_bx(arguments:, stdin_data:)
end

# Then #########################################################################

Then('bx outputs nothing to stdout') do
  assert_equal('', bx_result.stdout)
end

Then('bx outputs to stdout') do |stdout_content|
  assert_equal(stdout_content, bx_result.stdout)
end

Then('bx confirms nothing') do
  assert_equal('', bx_result.c)
end

Then('bx confirms') do |table|
  raise('Invalid confirmation table!') unless table.headers.include?('RECIPE')

  expected_confirmations = table.hashes.map do |row|
    build_confirmation_string(row['RECIPE'])
  end

  assert_equal(expected_confirmations.join("\n"), bx_result.c)
end

Then('bx traces nothing') do
  assert_equal('', bx_result.t)
end

Then('bx traces') do |trace_content|
  assert_equal(trace_content, bx_result.t)
end

Then('bx warns with message {string}') do |warning|
  assert_equal(warning, bx_result.e)
end

Then('bx does not error out') do
  assert_equal('', bx_result.e)
end

Then('bx errors out with message {string}') do |stderr_content|
  if stderr_content.empty?
    step('bx does not error out')
  else
    assert_equal(stderr_content, bx_result.e)
  end
end

Then(
  'bx errors out with message containing {string}'
) do |partial_stderr_content|
  assert_match(partial_stderr_content, bx_result.e)
end

Then('bx succeeds') do
  assert_equal(0, bx_result.status)
end

Then('bx fails') do
  assert_not_equal(0, bx_result.status)
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
