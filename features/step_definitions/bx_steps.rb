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
  assert_not_match(
    %r{\[STDERR\] bx: Invoke recipe `[^`]+`\? \[y/N\] },
    bx.outputs.join("\n")
  )
end

Then('bx outputs nothing') do
  assert_equal('', bx.outputs.join("\n"))
end

Then('bx outputs') do |table|
  expected_output_lines = table.hashes
  actual_output_lines = bx.outputs

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

    if expected_output_line.instance_of? Regexp
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

Then('recipes output') do |table|
  expected_output_lines = table.hashes

  actual_output_lines =
    bx.outputs.select do |line|
      line.start_with?('[STDOUT] ')
    end

  check_range = Range.new(
    0,
    [expected_output_lines.size, actual_output_lines.size].max - 1
  )

  check_range.each do |index|
    expected_output_line =
      expected_output_lines.fetch(index, {}).fetch('STDOUT', '')

    actual_output_line = actual_output_lines.fetch(index, '')

    assert_equal(
      "Line #{index + 1}: [STDOUT] #{expected_output_line}",
      "Line #{index + 1}: #{actual_output_line}"
    )
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
  output_type = data.fetch('TYPE', '')
  output_data = data.fetch('DATA', '')

  stream_name = %w[stdout bx-help].include?(output_type) ? 'STDOUT' : 'STDERR'

  if output_data.start_with?('/') && output_data.end_with?('/')
    return /\[#{stream_name}\].*#{output_data.slice(1, -1)}/
  end

  formatted_output =
    case output_type
    when 'bx-help'
      output_data.sub(/^(%%+)/) { |m| '    ' * (m.size / 2) }
    when 'bx-confirm'
      build_confirmation_string(output_data)
    when 'bx-in'
      invocation_stack << canonicalize_recipe_invocation(output_data)

      "#{'+' * invocation_stack.size} # #{invocation_stack.last} {"
    when 'bx-out'
      invocation_stack.pop

      "#{'+' * (invocation_stack.size + 1)} # }"
    when 'bx-skip'
      canonical_recipe_invocation = canonicalize_recipe_invocation(output_data)

      "bx: Skipping re-invocation of `#{canonical_recipe_invocation}`..."
    when 'bx-error'
      "bx: #{output_data}"
    when 'xtrace'
      "#{'+' * (invocation_stack.size + 1)} #{output_data}"
    when 'stdout', 'stderr'
      output_data
    else
      raise("Invalid output type '#{output_type}'!")
    end

  "[#{stream_name}] #{formatted_output}"
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
