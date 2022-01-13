# frozen_string_literal: true

#
# Copyright 2021-Ray Tung
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/formatter'

require 'pathname'
require 'google/protobuf'

require 'fluent/env'
require 'fluent/time'
require 'oj'

module Fluent
  module Plugin
    # ProtobufFormatter for Fluentd
    class ProtobufFormatter < Fluent::Plugin::Formatter
      Fluent::Plugin.register_formatter('protobuf', self)

      config_param :class_name,
                   :string,
                   desc: 'Ruby Protobuf class name. Used to encode into Protobuf binary'

      config_param :decode_json,
                   :bool,
                   default: false,
                   desc: <<~DESC
                     Serializes record from canonical proto3 JSON mapping (https://developers.google.com/protocol-buffers/docs/proto3#json) into binary'
                   DESC

      config_param :format_field,
                   :string,
                   default: '',
                   desc: <<~DESC
                     When defined, the plugin will only serialise the record in the given field rather than the whole record.
                      This is potentially useful if you intend to use this formatter with the Kafka output plugin
                      (https://github.com/fluent/fluent-plugin-kafka#output-plugin) for example, where your record contains
                      a field to determine which Kafka topic to write to, or the Kafka headers to include, but you do not
                      wish to include those data in the resulting proto3 binary.

                      Defaults to serialising the whole record.
                   DESC

      config_param :include_paths,
                   :array,
                   default: [],
                   desc: 'Generated Ruby Protobuf class files path'

      config_param :require_method,
                   :string,
                   default: 'require',
                   desc: <<~DESC
                     Determine how to bring the generated Ruby Protobuf class files into scope. If your generated Ruby Protobuf class files
                     are provided by a Ruby Gem, you would want to use \'require\'. If you are providing the generated files as files, you
                     may want to use \'require_relative\''
                   DESC

      def configure(conf)
        super(conf)

        raise Fluent::ConfigError, "Missing 'include_paths'" if @include_paths.empty?

        @include_paths.each { |path| require_proto!(path) } unless @include_paths.empty?

        class_lookup = Google::Protobuf::DescriptorPool.generated_pool.lookup(@class_name)
        raise Fluent::ConfigError, "class name '#{@class_name}' not found" if class_lookup.nil?

        @protobuf_class = class_lookup.msgclass
      end

      def formatter_type
        :binary
      end

      def format(_tag, _time, record)
        format_record = @format_field == '' ? record : record[@format_field]

        protobuf_msg = if @decode_json
                         @protobuf_class.decode_json(Oj.dump(format_record))
                       else
                         @protobuf_class.new(format_record)
                       end
        @protobuf_class.encode(protobuf_msg)
      end

      def require_proto!(filename)
        Kernel.method(@require_method.to_sym).call(filename)
      rescue LoadError => e
        raise Fluent::ConfigError, "Unable to load file '#{filename}'. Reason: #{e.message}"
      end
    end
  end
end
