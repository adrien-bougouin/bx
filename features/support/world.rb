# frozen_string_literal: true

require 'test/unit/assertions'

class TestContext
  include Test::Unit::Assertions

  class BxResult
    attr_reader :stdout, :stderr, :status, :c, :t, :e

    # rubocop:disable Metrics/ParameterLists, Naming/MethodParameterName
    def initialize(stdout, stderr, status, c, t, e)
      @stdout = stdout
      @stderr = stderr
      @status = status
      # TODO: Remove once implementing 'Then bx outputs to stderr'
      @c = c
      @t = t
      @e = e
    end
    # rubocop:enable Metrics/ParameterLists, Naming/MethodParameterName
  end

  attr_accessor :bash_env, :bx_options

  attr_reader :bx_result

  def initialize
    @bash_env = [
      'export TERM=',
      'export PS4="+ "'
    ]

    @bx_options = []
    @bx_result = nil
  end

  def call_bx(arguments: [], stdin_data: nil)
    stdout, stderr, status, c, t, e =
      Bx.new(bash_env: @bash_env, options: @bx_options)
        .call(arguments:, stdin_data:)

    @bx_result = BxResult.new(stdout, stderr, status, c, t, e)
  end
end

World { TestContext.new }
