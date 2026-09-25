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

    traces, errors = stderr.sub(/\n\Z/, '').split("\n").partition do |line|
      line.start_with?('+')
    end

    confirmations, errors = errors.partition do |line|
      line.match?(%r{^bx: .*\? \[y/N\] $})
    end

    [
      clean_output(stdout),
      clean_output(stderr),
      status.exitstatus,
      # TODO: Remove once implementing 'Then bx outputs to stderr'
      confirmations.map(&:strip).join("\n"),
      traces.join("\n"),
      errors.join("\n")
    ]
  end

  private

  def clean_output(output)
    output.sub(/\n\Z/, '')
  end
end
