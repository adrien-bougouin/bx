# frozen_string_literal: true

require 'open3'

class BX
  attr_reader :options, :outputs, :exit_status

  def initialize(context, options: [])
    @context = context
    @options = options
  end

  def call(arguments: [], stdin_data: nil)
    execution_script = <<~SH
      #{@context.env.join("\n")}

      bx #{@options.join(' ')} #{arguments.map(&:inspect).join(' ')}
    SH

    Open3.popen3(execution_script) do |stdin, stdout, stderr, wait_thr|
      outputs = +''

      stdin.write(stdin_data)
      stdin.close

      streams = [stdout, stderr]
      until streams.empty?
        readable, = IO.select(streams)

        readable.each do |io|
          data = io.read_nonblock(4096)
          stream_name = io == stdout ? 'STDOUT' : 'STDERR'

          outputs << data.gsub(/^/, "[#{stream_name}] ")
        rescue EOFError
          streams.delete(io)
        end
      end

      @outputs =
        outputs.sub(/\n\Z/, '')
               # Fix issue when capturing confirmation.
               .gsub(%r{(\[y/N\] )\[STDERR\] $}, '\1')
               .split("\n")

      @exit_status = wait_thr.value
    end
  end
end
