# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent/plugin/version'

Gem::Specification.new do |spec|
  spec.name = 'fluent-plugin-formatter-protobuf'
  spec.version = Fluent::Plugin::VERSION
  spec.authors = ['Ray Tung']
  spec.email = ['code@raytung.net']
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.summary = 'Protobuf formatter for Fluentd'
  spec.description = 'This is a Fluentd formatter plugin designed to convert Protobuf JSON into Protobuf binary'
  spec.homepage = 'https://github.com/raytung/fluent-plugin-formatter-protobuf'
  spec.license = 'Apache-2.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/raytung/fluent-plugin-formatter-protobuf'
  spec.metadata['changelog_uri'] = 'https://github.com/raytung/fluent-plugin-formatter-protobuf/blob/main/CHANGELOG.md'

  test_files, files = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files = files
  spec.executables = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = test_files
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.22'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'test-unit', '~> 3.3'
  spec.add_runtime_dependency 'fluentd', ['>= 1.0', '< 2']
  spec.add_runtime_dependency 'google-protobuf', '>= 3.21', '< 5.0'
  spec.add_runtime_dependency 'oj', '~> 3.13'
end
