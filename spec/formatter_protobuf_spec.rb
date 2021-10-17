# frozen_string_literal: true

require 'rspec'
require 'fluent/supervisor'
require 'stringio'

require 'fluent/plugin/formatter_protobuf'

describe 'FormatterProtobuf' do
  after do
    # Do nothing
  end

  describe 'when condition' do
    it 'succeeds' do
      # Using other characters as delimiter as I can't seem to be able to get the fluentd config to accept \n
      delimiter = '<>'
      Fluent::VERSION = 1
      opt = {
        **Fluent::Supervisor.default_options,
        log_level: Fluent::Log::LEVEL_FATAL,
        config_path: File.expand_path(File.join(__dir__, 'fluent.conf')),
        standalone_worker: true,
        conf_encoding: 'utf-8',
        inline_config: %(
<source>
    @type tcp
    tag tcp.events
    port 5170
    delimiter "#{delimiter}"
    <parse>
        @type json
    </parse>
</source>

<match tcp.events>
    @type stdout
    <format>
        @type protobuf
        message_name "Log"
        include_paths ["#{File.expand_path(File.join(__dir__, 'log_pb.rb'))}"]
    </format>
</match>
        )
      }
      fluentd = Fluent::Supervisor.new(opt)
      fluentd.configure(supervisor: false)

      # Copied from fluentd source code as I needed to trap STDOUT
      daemon_logger_opts = {
        log_level: opt[:log_level] - 1
      }

      out = StringIO.new.set_encoding(Encoding::BINARY)

      logger = ServerEngine::DaemonLogger.new(out, daemon_logger_opts)

      # Sorry :( Fluentd instantiates this global and I needed to overwrite it
      $log = Fluent::Log.new(logger)

      thread = Thread.new do
        fluentd.run_worker
      end

      # hack. We should be able to find better ways to determine if fluentd is running
      sleep(5)

      socket = TCPSocket.new('localhost', 5170)
      socket.write(%({"timestamp": 1634386250, "message":"hello!"}#{delimiter}))
      socket.close

      thread.kill

      log_message = Log.new({ timestamp: 1_634_386_250, message: 'hello!' })
      expected = Log.encode(log_message)

      # The stdout output plugin appends \n to each message
      expect(out.string).to eq("#{expected}\n")
    end
  end
end
