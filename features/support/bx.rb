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

      streams = [stderr, stdout]
      until streams.empty?
        readable, = IO.select(streams)

        readable.each do |io|
          line = io.gets

          if line
            stream_name = io == stdout ? 'STDOUT' : 'STDERR'

            outputs << line.gsub(/^/, "[#{stream_name}] ")
          else
            streams.delete(io)
          end
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
