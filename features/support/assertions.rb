# frozen_string_literal: true

class AssertionError < StandardError; end

def assert_equal(expected, actual, data_type: 'value')
  return if actual == expected

  raise AssertionError, "Expected #{data_type} #{expected.inspect} but got #{actual.inspect}"
end
