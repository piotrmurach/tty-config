# frozen_string_literal: true

if ENV["COVERAGE"] || ENV["TRAVIS"]
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

module TestHelpers
  module Paths
    def gem_root
      File.expand_path(File.join(File.dirname(__FILE__), ".."))
    end

    def dir_path(*args)
      path = File.join(gem_root, *args)
      FileUtils.mkdir_p(path) unless ::File.exist?(path)
      File.realpath(path)
    end

    def tmp_path(*args)
      File.join(dir_path("tmp"), *args)
    end

    def fixtures_path(*args)
      File.join(dir_path("spec/fixtures"), *args)
    end

    def within_dir(target, &block)
      ::Dir.chdir(target, &block)
    end
  end
end

RSpec.configure do |config|
  config.include(TestHelpers::Paths)
  config.disable_monkey_patching!
  config.after(:example, type: :cli) do
    FileUtils.rm_rf(tmp_path)
  end
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
