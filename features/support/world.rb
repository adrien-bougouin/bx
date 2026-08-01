# frozen_string_literal: true

require 'open3'

module ShellWorld
  class Shell
    attr_reader :stdout, :stderr, :status

    def execute(command)
      stdout, stderr, status = Open3.capture3("PS4='+ ' TERM= #{command}")

      @stdout = stdout.sub(/\n\Z/, '')
      @stderr = stderr.sub(/\n\Z/, '')
      @status = status.exitstatus
    end
  end

  def shell
    @shell ||= Shell.new
  end
end

World(ShellWorld)
