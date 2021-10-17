# frozen_string_literal: true

require 'rspec'
require 'fluent/supervisor'
require 'stringio'

require 'fluent/plugin/formatter_protobuf'
require 'net/http'
require 'uri'
require 'kafka'

describe 'FormatterProtobuf' do
  after do
    # Do nothing
  end

  describe 'when condition' do
    it 'succeeds' do
      kafka = Kafka.new(['broker:9092'])
      sleep 1

      kafka.create_topic('integration-tests', num_partitions: 1)

      uri = URI('http://fluentd:5170/tcp.events')
      res = Net::HTTP.post(uri, %({"timestamp": 1634386250, "message":"hello!"}))

      puts res.body

      kafka.each_message(topic: 'integration-tests') do |message|
        msg = Log.decode(message.value)

        puts msg
      end

      # log_message = Log.new({ timestamp: 1_634_386_250, message: 'hello!' })
      # expected = Log.encode(log_message)
      #
      # # The stdout output plugin appends \n to each message
      # expect(out.string).to eq("#{expected}\n")
    end
  end
end
