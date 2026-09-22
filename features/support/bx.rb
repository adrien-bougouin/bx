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

      bx #{@options.join(' ')} #{arguments.map(&:inspect).join(' ')} \
        2> >(awk '{print "[STDERR] " $0; fflush("")}' >&1) \
        1> >(awk '{print "[STDOUT] " $0; fflush("")}')
    BASH

    stdout, status = Open3.capture2(
      "bash -c #{Shellwords.escape(bash_script)}",
      stdin_data:
    )

    @outputs = stdout.sub(/\n\[STD(OUT|ERR)\] \Z/, '').split("\n")
    @exit_status = status.exitstatus
  end
end
