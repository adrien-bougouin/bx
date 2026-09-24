# frozen_string_literal: true

module GlobalScope
  def env
    @env ||= [
      'export TERM=',
      'export PS4="+ "'
    ]
  end

  def bx
    @bx ||= Bx.new(self)
  end
end

World(GlobalScope)
