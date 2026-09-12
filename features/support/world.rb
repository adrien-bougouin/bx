# frozen_string_literal: true

module GlobalScope
  def env
    @env ||= [
      'export TERM=',
      'export PS4="+ "'
    ]
  end

  def bx_options
    @bx_options ||= []
  end

  def bx
    @bx ||= BX.new(self)
  end
end

World(GlobalScope)
