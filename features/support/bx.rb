# frozen_string_literal: true

require 'open3'
require 'shellwords'

class Bx
  def initialize(bash_env: [], options: [])
    @bash_env = bash_env.join("\n")
    @options = options.join(' ')
  end

  def call(arguments: [], stdin_data: nil)
    bash_script = <<~BASH
      #{@bash_env}

      bx #{@options} #{arguments.map(&:inspect).join(' ')}
    BASH

    stdout, stderr, status = Open3.capture3(
      "bash -c #{Shellwords.escape(bash_script)}",
      stdin_data:
    )

    [clean_output(stdout), clean_output(stderr), status.exitstatus]
  end

  private

  def clean_output(output)
    output.sub(/\n\Z/, '')
  end
end
