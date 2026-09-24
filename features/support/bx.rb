# frozen_string_literal: true

require 'open3'
require 'shellwords'

class Bx
  attr_accessor :options

  attr_reader :output, :exit_status

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

    @output = stdout.sub(/\n\Z/, '')
    @exit_status = status.exitstatus
  end

  def output_lines
    @output_lines ||= @output.split("\n")
  end
end
