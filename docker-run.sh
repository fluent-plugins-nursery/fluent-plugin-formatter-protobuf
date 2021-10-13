#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

WORK_DIR="/opt/fluent-plugin-formatter-protobuf/"
GEMSPEC_CACHE_DIR="/root/.local/share/gem/specs"
GEM_PATHS="/root/.local/share/gem/ruby/3.0.0"
INSTALLATION_DIR="/usr/local/bundle"
PROJECT_CACHE="${PWD}/cache/"

docker run \
  -it \
  --rm \
  -v "${PWD}:${WORK_DIR}" \
  -v "${PROJECT_CACHE}/gem/specs:${GEMSPEC_CACHE_DIR}" \
  -v "${PROJECT_CACHE}/gem/ruby/3.0.0/:${GEM_PATHS}" \
  -v "${PROJECT_CACHE}/bundle/:${INSTALLATION_DIR}" \
  --workdir "${WORK_DIR}" \
  ruby:3.0.2 "$@"
