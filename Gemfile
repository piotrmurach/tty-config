# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "yardstick", "~> 0.9.9"

if RUBY_VERSION == "2.0.0"
  gem "json", "2.4.1"
  gem "rexml", "3.2.4"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.1.0")
  gem "rspec-benchmark", "~> 0.6.0"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.0")
  gem "coveralls_reborn", "~> 0.28.0"
  gem "simplecov", "~> 0.22.0"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0")
  gem "racc", "~> 1.7"
end
