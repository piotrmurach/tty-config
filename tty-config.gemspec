require_relative "lib/tty/config/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-config"
  spec.version       = TTY::Config::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = ["piotr@piotrmurach.com"]
  spec.summary       = %q{Define, read and write any Ruby app configurations with a penchant for terminal clients.}
  spec.description   = %q{Define, read and write any Ruby app configurations with a penchant for terminal clients.}
  spec.homepage      = "https://piotrmurach.github.io/tty"
  spec.license       = "MIT"
  spec.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "bug_tracker_uri"   => "https://github.com/piotrmurach/tty-config/issues",
    "changelog_uri"     => "https://github.com/piotrmurach/tty-config/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/tty-config",
    "homepage_uri"      => spec.homepage,
    "source_code_uri"   => "https://github.com/piotrmurach/tty-config"
  }
  spec.files         = Dir["lib/**/*", "README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.bindir        = "exe"
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "toml", "~> 0.2.0"
  spec.add_development_dependency "inifile", "~> 3.0.0"
  spec.add_development_dependency "rhcl", "~> 0.1.0"
end
