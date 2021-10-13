# frozen_string_literal: true

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs.push('lib', 'test')
    t.test_files = FileList['test/**/test_*.rb']
    t.verbose = true
    t.warning = true
  end
end

namespace :generate do
  desc 'Generates golden file for testing'
  task :golden do
    sh '\
cat ./test/proto/addressbook | \
protoc \
  --encode=tutorial.AddressBook \
  --proto_path=./test/proto/ \
  ./test/proto/addressbook.proto \
  > ./test/proto/addressbook.bin'
  end

  desc 'Generates Ruby Protobuf classes'
  task :proto do
    sh 'protoc --proto_path=./test/proto --ruby_out=./test/proto ./test/proto/addressbook.proto   '
  end
end

namespace :lint do
  desc 'Linting'
  task :check do
    sh 'rubocop'
  end

  desc 'Auto correcting lint errors'
  task :fix do
    sh 'rubocop --auto-correct'
  end
end

desc 'Listing all tasks'
task :help do
  sh 'rake --tasks'
end

task default: [:help]
