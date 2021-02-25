# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
  require "simplecov"
  require "coveralls"

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ])

  SimpleCov.start do
    command_name "spec"
    add_filter "spec"
  end
end

require "bundler/setup"
require "tty/config"
require "tmpdir"

module TestHelpers
  module Paths
    def fixtures_path(*args)
      ::File.join(__dir__, "fixtures", *args)
    end
  end
end

RSpec.shared_context "sandbox" do
  around(:each) do |example|
    ::Dir.mktmpdir do |dir|
      ::Dir.chdir(dir) do
        example.metadata[:tmpdir] = dir
        example.call
      end
    end
  end
end

RSpec.configure do |config|
  config.include(TestHelpers::Paths)
  config.include_context "sandbox", type: :sandbox

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
