#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

docker run -it --rm \
  -v "${PWD}:/opt/fluent-plugin-formatter-protobuf/" \
  -w '/opt/fluent-plugin-formatter-protobuf/' \
  -e OUT_FILE="./out" \
  -p 5170:5170 \
  ruby:3.0.1 sh -c 'bundle install && fluentd -c /opt/fluent-plugin-formatter-protobuf/fluent.conf'