# frozen_string_literal: true

require_relative "lib/tty/config/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-config"
  spec.version       = TTY::Config::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = %q{A highly customisable application configuration interface for building terminal tools.}
  spec.description   = %q{A highly customisable application configuration interface for building terminal tools. It supports many file formats such as YAML, JSON, TOML, INI, HCL and Java Properties.}
  spec.homepage      = "https://ttytoolkit.org"
  spec.license       = "MIT"
  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "bug_tracker_uri"   => "https://github.com/piotrmurach/tty-config/issues",
    "changelog_uri"     => "https://github.com/piotrmurach/tty-config/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/tty-config",
    "homepage_uri"      => spec.homepage,
    "source_code_uri"   => "https://github.com/piotrmurach/tty-config"
  }
  spec.files         = Dir["lib/**/*"]
  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.bindir        = "exe"
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "inifile", "~> 3.0"
  spec.add_development_dependency "java-properties", "~> 0.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rhcl", "~> 0.1"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "toml", "~> 0.2"
  spec.add_development_dependency "xml-simple", "~> 1.1"
end
