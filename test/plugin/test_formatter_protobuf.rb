# frozen_string_literal: true

require 'helper'
require 'fluent/plugin/formatter_protobuf'

class ProtobufFormatterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  VALID_INCLUDE_PATHS = [File.expand_path(File.join(__dir__, '..', 'proto', 'addressbook_pb.rb'))].freeze

  sub_test_case 'configure' do
    test 'fail if include_paths is empty' do
      assert_raise(Fluent::ConfigError) do
        create_driver({ message_name: '', include_paths: [] })
      end
    end

    test 'fail if no protobuf class can be found with message_name' do
      assert_raise(Fluent::ConfigError) do
        create_driver({ message_name: 'Some.Name', include_paths: VALID_INCLUDE_PATHS })
      end
    end

    test 'passes on valid configuration' do
      assert_nothing_raised do
        create_driver({ message_name: 'tutorial.AddressBook', include_paths: VALID_INCLUDE_PATHS })
      end
    end
  end

  sub_test_case 'format' do
    test 'encodes into Protobuf binary' do
      formatter = create_formatter({ message_name: 'tutorial.AddressBook', include_paths: VALID_INCLUDE_PATHS })

      formatted = formatter.format('some-tag', 1234,
                                   { people: [{ name: 'Masahiro', id: 1337, email: 'repeatedly _at_ gmail.com' }] })
      golden_file = File.binread(File.expand_path(File.join(__dir__, '..', 'proto', 'addressbook.bin')))
      assert_equal(golden_file, formatted)
    end
  end

  private

  def create_driver(conf = {})
    Fluent::Test::Driver::Formatter.new(Fluent::Plugin::ProtobufFormatter).configure(conf)
  end

  def create_formatter(conf)
    create_driver(conf).instance
  end
end
