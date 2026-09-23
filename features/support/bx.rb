# frozen_string_literal: true

require 'open3'
require 'shellwords'

class BX
  attr_reader :options, :outputs, :exit_status

  def initialize(context, options: [])
    @context = context
    @options = options
  end

  def call(arguments: [], stdin_data: nil)
    bash_script = <<~BASH
      #{@context.env.join("\n")}

      bx #{@options.join(' ')} #{arguments.map(&:inspect).join(' ')}
    BASH

    stdout, status = Open3.capture2e(
      "bash -c #{Shellwords.escape(bash_script)}",
      stdin_data:
    )

    @outputs = stdout.sub(/\n\Z/, '').split("\n")
    @exit_status = status.exitstatus
  end
end
