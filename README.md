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

## Not so quick start

1. Generate the protobuf ruby methods
   1. e.g `protoc --proto_path=. --ruby_out=. ./log.proto`
2. Modify the `<format>` section to include `message_name`, which is your Protobuf message name, and `include_paths`, the path where the generated Ruby types are stored


## Example

```fluentd
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
    @type file

    path /opt/fluent-plugin-formatter-protobuf/out

    <buffer>
        @type memory
    </buffer>

    <format>
        @type protobuf
        message_name "Log"
        include_paths ["/opt/fluent-plugin-formatter-protobuf/log_pb.rb"]
    </format>
</match>
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-config-format formatter formatter-protobuf
```

You can copy and paste generated documents here.

## Copyright

* Copyright(c) 2021 - Ray Tung
* License
  * Apache License, Version 2.0
