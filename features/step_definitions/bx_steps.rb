# frozen_string_literal: true

require 'shellwords'

# When #########################################################################

When('setting') do |table|
  raise('Invalid settings!') unless table.headers.include?('OPTION')

  bx.options += table.hashes.map { |r| r['OPTION'] }
end

When('invoking') do |*args|
  table = args.first

  bx_arguments = []
  bx_stdin_data = nil

  if table
    raise('Invalid invocation table!') unless table.headers.include?('RECIPE')

    invocation_list = table.hashes

    recipe_invocations = invocation_list.map do |row|
      row['RECIPE']
    end.reject(&:empty?)

    confirmations = invocation_list.map do |row|
      row['CONFIRMATION'] || ''
    end.reject(&:empty?)

    bx_arguments = recipe_invocations
    bx_stdin_data = confirmations.join unless confirmations.empty?
  end

  bx.call(arguments: bx_arguments, stdin_data: bx_stdin_data)
end

# Then #########################################################################

Then('bx confirms nothing') do
  assert_not_match(%r{bx: Invoke recipe `[^`]+`\? \[y/N\]}, bx.output)
end

Then('bx outputs nothing') do
  assert_equal('', bx.output)
end

Then('bx outputs') do |table_or_text|
  if table_or_text.instance_of?(String)
    assert_equal(table_or_text, bx.output)
    next
  end

  expected_output_lines = table_or_text.hashes
  actual_output_lines = bx.output_lines

  check_range = Range.new(
    0,
    [expected_output_lines.size, actual_output_lines.size].max - 1
  )

  check_range.each_with_object([]) do |index, invocation_stack|
    expected_output_line = build_expected_output_line(
      expected_output_lines.fetch(index, {}),
      invocation_stack:
    )
    actual_output_line = actual_output_lines.fetch(index, '')

    if expected_output_line.instance_of?(Regexp)
      assert_match(
        expected_output_line,
        "Line #{index + 1}: #{actual_output_line}"
      )
    else
      assert_equal(
        "Line #{index + 1}: #{expected_output_line}",
        "Line #{index + 1}: #{actual_output_line}"
      )
    end
  end
end

Then('bx succeeds') do
  assert_equal(0, bx.exit_status)
end

Then('bx fails') do
  assert_not_equal(0, bx.exit_status)
end

# Helpers ######################################################################

def build_expected_output_line(data, invocation_stack: [])
  output_format = data.fetch('FORMAT', '')
  output_data = data.fetch('DATA', '')

  if output_data.start_with?('/') && output_data.end_with?('/')
    return /#{output_data.slice(1, -1)}/
  end

  case output_format
  when 'bx-confirm'
    build_confirmation_string(output_data)
  when 'bx-error'
    "bx: #{output_data}"
  when 'bx-in'
    invocation_stack << canonicalize_recipe_invocation(output_data)

    "#{'+' * invocation_stack.size} # #{invocation_stack.last} {"
  when 'bx-out'
    invocation_stack.pop

    "#{'+' * (invocation_stack.size + 1)} # }"
  when 'bx-skip'
    canonical_recipe_invocation = canonicalize_recipe_invocation(output_data)

    "bx: Skipping re-invocation of `#{canonical_recipe_invocation}`..."
  when 'xtrace'
    "#{'+' * (invocation_stack.size + 1)} #{output_data}"
  when ''
    output_data
  else
    raise("Invalid format '#{output_format}'!")
  end
end

def build_confirmation_string(recipe_invocation)
  canonical_recipe_invocation = canonicalize_recipe_invocation(
    recipe_invocation
  )

  "bx: Invoke recipe `#{canonical_recipe_invocation}`? [y/N] "
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
