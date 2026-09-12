# frozen_string_literal: true

require 'open3'

class BX
  attr_reader :stdout, :confirmations, :xtrace, :stderr, :status

  def initialize(context)
    @context = context
  end

  def call(arguments: '', stdin_data: nil)
    stdout, stderr, status = Open3.capture3(
      "#{@context.env.join("\n")}\nbx #{@context.bx_options.join(' ')} #{arguments}",
      stdin_data:
    )

    traces, errors = stderr.sub(/\n\Z/, '').split("\n").partition do |line|
      line.start_with?('+')
    end

    confirmations, errors = errors.partition do |line|
      line.match?(%r{^bx: .*\? \[y/N\] $})
    end

    @stdout = stdout.sub(/\n\Z/, '')
    @confirmations = confirmations.map(&:strip).join("\n")
    @xtrace = traces.join("\n")
    @stderr = errors.join("\n")
    @status = status.exitstatus
  end
end
