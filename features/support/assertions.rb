# frozen_string_literal: true

class AssertionError < StandardError; end

def assert_equal(expected, actual, data_type: 'value')
  return if actual == expected

  raise AssertionError, "Expected #{data_type} #{expected.inspect} but got #{actual.inspect}"
end

def assert_not_equal(expected, actual, data_type: 'value')
  return if actual != expected

  raise AssertionError, "Expected #{data_type} #{expected.inspect} to not be #{actual.inspect}"
end

def assert_include(expected, actual, data_type: 'value')
  return if actual.include?(expected)

  raise AssertionError, "Expected #{data_type} #{expected.inspect} to be included in #{actual.inspect}"
end
