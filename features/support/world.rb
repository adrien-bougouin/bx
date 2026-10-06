# frozen_string_literal: true

require 'test/unit/assertions'

class TestContext
  include Test::Unit::Assertions

  class BxResult
    attr_reader :stdout, :stderr, :status

    def initialize(stdout, stderr, status)
      @stdout = stdout
      @stderr = stderr
      @status = status
    end
  end

  attr_accessor :bash_env, :bx_options

  attr_reader :bx_result

  def initialize
    @bash_env = ['export PS4="+ "']
    @bx_options = []
    @bx_result = nil
  end

  def call_bx(arguments: [], stdin_data: nil)
    bx = Bx.new(bash_env: @bash_env, options: @bx_options)

    @bx_result = BxResult.new(
      *bx.call(arguments:, stdin_data:)
    )
  end
end

World { TestContext.new }
