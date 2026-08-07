# frozen_string_literal: true

require 'open3'

module ShellWorld
  class Shell
    attr_reader :stdout, :stderr, :xtrace, :status

    def execute(command)
      stdout, stderr, status = Open3.capture3(
        "TERM= PS4='+ ' #{command}"
      )

      # FIXME: Eventually, separating stderr and trace by /^+/ pattern may fail
      traces, errors = stderr.sub(/\n\Z/, '').split("\n").partition do |line|
        line.start_with?('+')
      end

      @stdout = stdout.sub(/\n\Z/, '')
      @stderr = errors.join("\n")
      @xtrace = traces.join("\n")
      @status = status.exitstatus
    end
  end

  def shell
    @shell ||= Shell.new
  end
end

World(ShellWorld)
