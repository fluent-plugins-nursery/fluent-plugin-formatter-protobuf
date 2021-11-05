# fluent-plugin-formatter-protobuf

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-formatter-protobuf.svg)](https://badge.fury.io/rb/fluent-plugin-formatter-protobuf)

[Fluentd](https://fluentd.org/) formatter plugin to format messages into Protobuf v3 encoded binary.

## Installation

### RubyGems

```shell
$ gem install fluent-plugin-formatter-protobuf
```

### GitHub RubyGems Registry

```shell
$ gem install \
  fluent-plugin-formatter-protobuf \
  --version "<version>" \
  --source "https://rubygems.pkg.github.com/fluent-plugins-nursery"
```

### Bundler (RubyGems)

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-formatter-protobuf", "<version>"
```

### Bundler (GitHub RubyGems Registry),

```shell
source "https://rubygems.pkg.github.com/fluent-plugins-nursery" do
  gem "fluent-plugin-formatter-protobuf", "<version>"
end
```

And then execute:

```
$ bundle
```

## Quick start

1. Generate the protobuf ruby methods
   1. e.g `protoc --proto_path=. --ruby_out=. ./log.proto`
2. Modify the `<format>` section to include `class_name`, which is your Protobuf message name, and `include_paths`, the path where the generated Ruby types are stored
   1. Given protobuf class `Your::Protobuf::Class::Name` class should be given as `Your.Protobuf.Class.Name` in `class_name`. The exact name can be found in the generated Ruby files

## Note

This plugin only supports Protobuf v3.

## Example

```aconf
<source>
    @type tcp
    tag tcp.events
    port 5170
    delimiter "\n"
    <parse>
        @type json
    </parse>
</source>

<match tcp.events>
    @type kafka2
    
    brokers "#{BROKER_ENDPOINTS}"
    compression_codec lz4

    <buffer topic>
        @type memory
        flush_interval 5s
    </buffer>

    <format>
        @type protobuf
        class_name "Log"
        include_paths ["/opt/fluent-plugin-formatter-protobuf/log_pb.rb"]
    </format>
</match>
```

## Configuration

|parameter|type|description|default|
|---|---|---|---|
|include_paths|array (optional)| Generated Ruby Protobuf class files path |`[]`|
|class_name|string (required)| Ruby Protobuf class name. Used to encode into Protobuf binary||

## Tips

#### 1. I have multiple `_pb.rb` files and they depend on one another. When I use this plugin, I'm getting a `LoadError`.

This happens because the plugin currently loads paths in `include_paths` sequentially. You can either sort the files in correct dependency order (which is cumbersome), or add to Ruby's `$LOAD_PATH`.

For example, you have 2 generated ruby files, `a_pb.rb` and `b_pb.rb`, and both `a_pb.rb` depends on `b_pb.rb`.

You can either order them in appropriate dependency order, such as

```aconf
<format>
  @type protobuf
  class_name "SomePackage.A"
  include_paths ["/some/path/b_pb.rb", "/some/path/a_pb.rb"]
</format>

```

or you can put the generated files in a directory say `/some/path/`, and add to Ruby's `$LOAD_PATH` via the `RUBYLIB` environment variable.

e.g.

```aconf
<format>
  @type protobuf
  class_name "SomePackage.A"
  include_paths ["/some/path/a_pb.rb"]
</format>

```

```shell

export RUBYLIB="${RUBYLIB}:/some/path/"
fluentd \
  --gemfile "/some/other/path/Gemfile" \
  --config "/some/other/path/fluent.conf"

```

## License

[Apache License, Version 2.0](./LICENSE)
