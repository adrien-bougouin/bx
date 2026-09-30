# frozen_string_literal: true

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

Then('bx outputs nothing to stderr') do
  assert_equal('', bx_result.stderr)
end

Then('bx confirms nothing') do
  assert_not_match(%r{^bx: Invoke recipe `[^`]+`? [y/N] $}, bx_result.stderr)
end

Then('bx outputs to stdout') do |expected_content|
  assert_equal(expected_content, bx_result.stdout)
end

Then('bx outputs to stderr') do |table|
  expected_lines = table.hashes
  actual_lines = bx_result.stderr.split("\n")

  check_range =
    Range.new(0, [expected_lines.size, actual_lines.size].max - 1)

  check_range.each_with_object([]) do |index, invocation_stack|
    expected_line = build_expected_output_line(
      expected_lines.fetch(index, {}),
      invocation_stack:
    )
    actual_line = actual_lines.fetch(index, '')

    if expected_line.instance_of?(Regexp)
      assert_match(expected_line, actual_line)
    else
      assert_equal(expected_line, actual_line)
    end
  end
end

Then('bx succeeds') do
  assert_equal(0, bx_result.status)
end

Then('bx fails') do
  assert_not_equal(0, bx_result.status)
end

# Helpers ######################################################################

def build_expected_output_line(data, invocation_stack: [])
  format = data.fetch('FORMAT', '')
  content = data.fetch('CONTENT', '')

  if content.start_with?('/') && content.end_with?('/')
    return /#{content[1..-2]}/
  end

  case format
  when 'bx-confirm'
    build_confirmation_string(content)
  when 'bx-error'
    "bx: #{content}"
  when 'bx-miss'
    canonical_recipe_invocation = canonicalize_recipe_invocation(content)

    "bx: No recipe `#{canonical_recipe_invocation}`!"
  when 'bx-trace-in'
    invocation_stack << canonicalize_recipe_invocation(content)

    "#{'+' * invocation_stack.size} # #{invocation_stack.last} {"
  when 'bx-trace-out'
    invocation_stack.pop

    "#{'+' * (invocation_stack.size + 1)} # }"
  when 'bx-skip'
    canonical_recipe_invocation = canonicalize_recipe_invocation(content)

    "bx: Skipping re-invocation of `#{canonical_recipe_invocation}`..."
  when 'xtrace'
    "#{'+' * (invocation_stack.size + 1)} #{content}"
  when ''
    content
  else
    raise("Invalid format '#{format}'!")
  end
end

def build_confirmation_string(recipe_invocation)
  canonical_recipe_invocation = canonicalize_recipe_invocation(
    recipe_invocation
  )

  "bx: Invoke recipe `#{canonical_recipe_invocation}`? [y/N] "
end

# Format test arguments as expected from bx's canonicalization.
#
# Its important that this function remains dumb simple. It does not have to
# handle every cases, as long as it supports the arguments we use in our tests.
#
# Note: The current expected canonical format produced by bx is not compatible
#       with Bash arguments.
def canonicalize_recipe_invocation(recipe_invocation)
  recipe, arguments_string = recipe_invocation.split(' ', 2)
  return recipe if arguments_string.nil?

  # 1. Remove single/double quotes around arguments' partial/full content and
  #    escape their enclosed spaces.
  #    Example: `--arg="arg 1"` => `--arg=arg\ 1`
  # 2. Surround args with single quotes.
  #    Example: `--arg=arg\ 1 --arg=arg\ 2` => `'--arg=arg\ 1' '--arg=arg\ 2'`
  canonical_arguments_string =
    arguments_string&.gsub(/"[^"]+"/) { |m| m[1..-2].gsub(' ', '\ ') } # Step 1
                    &.gsub(/'[^']+'/) { |m| m[1..-2].gsub(' ', '\ ') } # "
                    &.gsub(/([^\\]) (.)/, '\1\' \'\2')                 # Step 2
                    &.gsub(/^|$/, "'")                                 # "

  "#{recipe} #{canonical_arguments_string}"
end
