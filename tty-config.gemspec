lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tty/config/version"

Gem::Specification.new do |spec|
  spec.name          = "tty-config"
  spec.version       = TTY::Config::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]

  spec.summary       = %q{Define, read and write any Ruby app configurations with a penchant for terminal clients.}
  spec.description   = %q{Define, read and write any Ruby app configurations with a penchant for terminal clients.}
  spec.homepage      = "https://piotrmurach.github.io/tty"
  spec.license       = "MIT"

  spec.files         = Dir['{lib,spec}/**/*.rb']
  spec.files        += Dir['{bin,tasks}/*', 'tty-config.gemspec']
  spec.files        += Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt', 'Rakefile']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "toml", "~> 0.2.0"
  spec.add_development_dependency "inifile", "~> 3.0.0"
end
