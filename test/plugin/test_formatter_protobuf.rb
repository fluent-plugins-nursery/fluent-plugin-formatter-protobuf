# frozen_string_literal: true

require 'helper'
require 'fluent/plugin/formatter_protobuf'

class ProtobufFormatterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  VALID_INCLUDE_PATHS_ABSOLUTE = [File.expand_path(File.join(__dir__, '..', 'proto', 'addressbook_pb.rb'))].freeze

  # Relative to the plugin file
  VALID_INCLUDE_PATHS_RELATIVE = '../../../test/proto/addressbook_pb.rb'

  sub_test_case 'configure' do
    test 'fail if include_paths is empty' do
      assert_raise(Fluent::ConfigError) do
        create_driver({ class_name: '', include_paths: [] })
      end
    end

    test 'fail if ruby files not found in the provided include paths' do
      assert_raise(Fluent::ConfigError) do
        create_driver({ class_name: 'tutorial.AddressBook', include_paths: ['some/random/path'] })
      end
    end

    test 'fail if no protobuf class can be found with class_name' do
      assert_raise(Fluent::ConfigError) do
        create_driver({ class_name: 'Some.Name', include_paths: VALID_INCLUDE_PATHS_ABSOLUTE })
      end
    end

    test 'success if given valid relative paths in include paths' do
      assert_nothing_raised do
        create_driver({ class_name: 'tutorial.AddressBook', include_paths: [VALID_INCLUDE_PATHS_RELATIVE] })
      end
    end

    test 'passes on valid configuration' do
      assert_nothing_raised do
        create_driver({ class_name: 'tutorial.AddressBook', include_paths: VALID_INCLUDE_PATHS_ABSOLUTE })
      end
    end
  end

  stub_ruby_hash = { people: [{ name: 'Masahiro', id: 1337,
                                email: 'repeatedly _at_ gmail.com',
                                last_updated: {
                                  seconds: 1_638_489_505,
                                  nanos: 318_000_000
                                } }] }
  sub_test_case 'format' do
    test 'encodes into Protobuf binary' do
      formatter = create_formatter({ class_name: 'tutorial.AddressBook',
                                     include_paths: VALID_INCLUDE_PATHS_ABSOLUTE })

      formatted = formatter.format('some-tag', 1234,
                                   { people: [{ name: 'Masahiro', id: 1337, email: 'repeatedly _at_ gmail.com',
                                                last_updated: { seconds: 1_638_489_505, nanos: 318_000_000 } }] })
      address_book = Tutorial::AddressBook.new(stub_ruby_hash)
      assert_equal(Tutorial::AddressBook.encode(address_book), formatted)
    end

    test 'encodes Protobuf JSON format into Protobuf binary if config_param decode_json is true' do
      formatter = create_formatter({ class_name: 'tutorial.AddressBook',
                                     decode_json: true,
                                     include_paths: VALID_INCLUDE_PATHS_ABSOLUTE })

      formatted = formatter.format('some-tag', 1234,
                                   { people: [{ name: 'Masahiro', id: 1337, email: 'repeatedly _at_ gmail.com',
                                                last_updated: '2021-12-02T23:58:25.318Z' }] })

      address_book = Tutorial::AddressBook.new(stub_ruby_hash)
      assert_equal(Tutorial::AddressBook.encode(address_book), formatted)
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
