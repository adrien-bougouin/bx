# frozen_string_literal: true

require 'open3'

module ShellWorld
  class Shell
    attr_reader :stdout, :confirmations, :xtrace, :stderr, :status

    def execute(command, stdin_data: nil)
      stdout, stderr, status = Open3.capture3(
        "TERM= PS4='+ ' #{command}",
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

  def shell
    @shell ||= Shell.new
  end
end

World(ShellWorld)
