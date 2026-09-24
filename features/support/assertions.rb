# frozen_string_literal: true

class AssertionError < StandardError; end

def assert_equal(expected, actual)
  return if actual == expected

  raise(
    AssertionError,
    "Expected #{expected.inspect} but got #{actual.inspect}"
  )
end

def assert_not_equal(expected, actual)
  return if actual != expected

  raise(
    AssertionError,
    "Expected #{expected.inspect} to not be #{actual.inspect}"
  )
end

def assert_match(expected_pattern, actual)
  return if expected_pattern.match?(actual)

  raise(
    AssertionError,
    "Expected #{actual} to match #{expected_pattern.inspect}"
  )
end

def assert_not_match(expected_pattern, actual)
  return unless expected_pattern.match?(actual)

  raise(
    AssertionError,
    "Expected #{actual} to match #{expected_pattern.inspect}"
  )
end
