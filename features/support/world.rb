# frozen_string_literal: true

require 'test/unit/assertions'

module TestContext
  include Test::Unit::Assertions

  def env
    @env ||= [
      'export TERM=',
      'export PS4="+ "'
    ]
  end

  def bx
    @bx ||= BX.new(self)
  end
end

World(TestContext)
