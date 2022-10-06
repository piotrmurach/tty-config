<div align="center">
  <a href="https://ttytoolkit.org"><img width="130" src="https://github.com/piotrmurach/tty/raw/master/images/tty.png" alt="TTY Toolkit logo" /></a>
</div>

# TTY::Config [![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]

[![Gem Version](https://badge.fury.io/rb/tty-config.svg)][gem]
[![Actions CI](https://github.com/piotrmurach/tty-config/workflows/CI/badge.svg?branch=master)][gh_actions_ci]
[![Build status](https://ci.appveyor.com/api/projects/status/2383i0dn3hlw9cnn?svg=true)][appveyor]
[![Maintainability](https://api.codeclimate.com/v1/badges/dfac05073e1549e9dbb6/maintainability)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-config/badge.svg)][coverage]
[![Inline docs](https://inch-ci.org/github/piotrmurach/tty-config.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/tty
[gem]: https://badge.fury.io/rb/tty-config
[gh_actions_ci]: https://github.com/piotrmurach/tty-config/actions?query=workflow%3ACI
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-config
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-config/maintainability
[coverage]: https://coveralls.io/github/piotrmurach/tty-config
[inchpages]: https://inch-ci.org/github/piotrmurach/tty-config

> A highly customisable application configuration interface for building terminal tools.

**TTY::Config** provides application configuration component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Features

This is a one-stop shop for all your configuration needs:

* [Read](#216-read) and [write](#217-write) config files in YAML, JSON, TOML, INI, XML, HCL and Java Properties formats
* Add [custom marshallers](#222-register_marshaller) or override the built-in ones
* [Set](#21-set) and [read](#24-fetch) settings for deeply nested keys
* [Set](#21-set) defaults for undefined settings
* [Read](#24-fetch) settings with indifferent access
* [Merge](#25-merge) configuration settings from other hash objects
* Read values from [environment variables](#23-set_from_env)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "tty-config"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-config

## Contents

* [1. Usage](#1-usage)
  * [1.1 app](#11-app)
* [2. Interface](#2-interface)
  * [2.1 set](#21-set)
  * [2.2 set_if_empty](#22-set_if_empty)
  * [2.3 set_from_env](#23-set_from_env)
  * [2.4 fetch](#24-fetch)
  * [2.5 merge](#25-merge)
  * [2.6 coerce](#26-coerce)
  * [2.7 append](#27-append)
  * [2.8 remove](#28-remove)
  * [2.9 delete](#29-delete)
  * [2.10 alias_setting](#210-alias_setting)
  * [2.11 validate](#211-validate)
  * [2.12 filename=](#212-filename)
  * [2.13 extname=](#213-extname)
  * [2.14 append_path](#214-append_path)
  * [2.15 prepend_path](#215-prepend_path)
  * [2.16 read](#216-read)
  * [2.17 write](#217-write)
  * [2.18 exist?](#218-exist)
  * [2.19 env_prefix=](#219-env_prefix)
  * [2.20 env_separator=](#220-env_separator)
  * [2.21 autoload_env](#221-autoload_env)
  * [2.22 register_marshaller](#222-register_marshaller)
  * [2.23 unregister_marshaller](#223-unregister_marshaller)
* [3. Examples](#3-examples)
  * [3.1 Working with env vars](#31-working-with-env-vars)
  * [3.2 Working with optparse](#32-working-with-optparse)

## 1. Usage

Initialize the configuration and provide the name:

```ruby
config = TTY::Config.new
config.filename = "investments"
```

Then configure values for different nested keys with `set` and `append`:

```ruby
config.set(:settings, :base, value: "USD")
config.set(:settings, :color, value: true)
config.set(:coins, value: ["BTC"])

config.append("ETH", "TRX", "DASH", to: :coins)
```

You can get any value by using `fetch`:

```ruby
config.fetch(:settings, :base)
# => "USD"

config.fetch(:coins)
# => ["BTC", "ETH", "TRX", "DASH"]
```

And call `write` to persist the configuration to `investments.yml` file:

```ruby
config.write
# =>
# ---
# settings:
#   base: USD
#   color: true
# coins:
#  - BTC
#  - ETH
#  - TRX
#  - DASH
```

To read an `investments.yml` file, you need to provide the locations to search in:

```ruby
config.append_path Dir.pwd
config.append_path Dir.home
```

Finally, call `read` to convert configuration file back into an object again:

```ruby
config.read
```

### 1.1 app

An example of an application configuration:

```ruby
class App
  attr_reader :config

  def initialize
    @config = TTY::Config.new
    @config.filename = "investments"
    @config.extname = ".toml"
    @config.append_path Dir.pwd
    @config.append_path Dir.home
  end

  def self.config
    @config ||= self.new.config
  end
end
```

## 2. Interface

### 2.1 set

To set configuration setting use `set` method. It accepts any number of keys and value by either using `:value` keyword argument or passing a block:

```ruby
config.set(:base, value: "USD")
config.set(:base) { "USD" }
```

The block version of specifying a value will mean that the value is evaluated every time it's being read.

You can also specify deeply nested configuration settings by passing sequence of keys:

```ruby
config.set(:settings, :base, value: "USD")
```

Which is equivalent to:

```ruby
config.set("settings.base", value: "USD")
```

Internally all configuration settings are stored as string keys for ease of working with configuration files and command line application's inputs.

### 2.2 set_if_empty

To set a configuration setting only if it hasn't been set before use `set_if_empty`:

```ruby
config.set_if_empty(:base, value: "USD")
```

Similar to `set` it allows you to specify arbitrary sequence of keys followed by a key value or block:

```ruby
config.set_if_empty(:settings, :base, value: "USD")
```

### 2.3 set_from_env

To read configuration options from environment variables use `set_from_env`. At minimum it requires a single argument which will match the name of `ENV` variable. The name of this parameter is case insensitive.

Given the following environment variables:

```ruby
ENV["HOST"] = "192.168.1.17"
ENV["PORT"] = "7727"
```

You can make the config aware of the above env variables:

```ruby
config.set_from_env(:host)
config.set_from_env(:port)
```

Then you can retrieve values like any other configuration option:

```ruby
config.fetch(:host)
# => "192.168.1.17"
config.fetch(:port)
# => "7727"
```

If you want the configuration key name to be different from `ENV` variable name use a block:

```ruby
config.set_from_env(:host) { "HOSTNAME" }
config.set_from_env(:host) { :hostname }
```

You can also configure settings for deeply nested keys:

```ruby
config.set_from_env(:settings, :base) { "CURRENCY" }
config.set_from_env(:settings, :base) { :currency }
config.set_from_env("settings.base") { "CURRENCY" }
config.set_from_env("settings.base") { :currency }
```

And assuming `ENV["CURRENCY"]=USD`:

```ruby
config.fetch(:settings, :base)
# => USD
```

You can also prefix your environment variables with [env_prefix=](#219-env_prefix) or use a different separator with [env_separator](#220-env_separator).

It's important to recognise that `set_from_env` doesn't record the value for the environment variables. They are read each time from the `ENV` when `fetch` is called.

### 2.4 fetch

To get a configuration setting use `fetch`, which can accept default value either with a `:default` keyword or a block that will be lazy evaluated:

```ruby
config.fetch(:base, default: "USD")
config.fetch(:base) { "USD" }
```

Similar to `set` operation, `fetch` allows you to retrieve deeply nested values:

```ruby
config.fetch(:settings, :base) # => USD
```

Which is equivalent to:

```ruby
config.fetch("settings.base")
```

`fetch` has indifferent access so you can mix string and symbol keys, all the following examples retrieve the value:

```ruby
config.fetch(:settings, :base)
config.fetch("settings", "base")
config.fetch(:settings, "base")
config.fetch("settings", :base)
```

### 2.5 merge

To merge in other configuration settings as hash use `merge`:

```ruby
config.set(:a, :b, value: 1)
config.set(:a, :c, value: 2)

config.merge({"a" => {"c" => 3, "d" => 4}})

config.fetch(:a, :c) # => 3
config.fetch(:a, :d) # => 4
```

Internally all configuration settings are stored as string keys for ease of working with file values and command line applications inputs.

### 2.6 coerce

You can initialize configuration based on a hash, with all the keys converted to symbols:

```ruby
hash = {"settings" => {"base" => "USD", "exchange" => "CCCAGG"}}
config = TTY::Config.coerce(hash)
config.to_h
# =>
# {settings: {base: "USD", exchange: "CCCAGG"}}
```

### 2.7 append

To append arbitrary number of values to a value under a given key use `append`:

```ruby
config.set(:coins) { ["BTC"] }

config.append("ETH", "TRX", to: :coins)
# =>
# {coins: ["BTC", "ETH", "TRX"]}
```

You can also append values to deeply nested keys:

```ruby
config.set(:settings, :bases, value: ["USD"])

config.append("EUR", "GBP", to: [:settings, :bases])
# =>
# {settings: {bases: ["USD", "EUR", "GBP"]}}
```

### 2.8 remove

Use `remove` to remove a set of values from a key.

```ruby
config.set(:coins, value: ["BTC", "TRX", "ETH", "DASH"])

config.remove("TRX", "DASH", from: :coins)
# =>
# ["BTC", "ETH"]
```

If the key is nested the `:from` accepts an array:

```ruby
config.set(:holdings, :coins, value: ["BTC", "TRX", "ETH", "DASH"])

config.remove("TRX", "DASH", from: [:holdings, :coins])
# =>
# ["BTC", "ETH"]
```

### 2.9 delete

To completely delete a value and corresponding key use `delete`:

```ruby
config.set(:base, value: "USD")
config.delete(:base)
# =>
# "USD"
```

You can also delete deeply nested keys and their values:

```ruby
config.set(:settings, :base, value: "USD")
config.delete(:settings, :base)
# =>
# "USD"
```

You can provide an optional default value in a block that will be returned when a key is not set:

```ruby
config.delete(:settings, :unknown) { |key| "#{key} isn't set" }
# =>
# "unknown isn't set"
```

### 2.10 alias_setting

In order to alias a configuration setting to another name use `alias_setting`.

For example, given an already existing setting:

```ruby
config.set(:base, value: "baz")
```

You can alias it to another name:

```ruby
config.alias_setting(:base, to: :currency)
```

And then access like any other configuration setting:

```ruby
config.fetch(:currency)
# => "USD"
```

Deep nested configuration options are also supported:

```ruby
config.set(:settings, :base, value: "USD")
```

And then can be aliased like so:

```ruby
config.alias_setting(:settings, :base, to: [:settings, :currency])
config.alias_setting("settings.base", to [:settings, :currency])
```

You can then access the deep nested settings:

```ruby
config.fetch(:settings, :currency)
# => "USD"
config.fetch("settings.currency")
# => "USD"
```

### 2.11 validate

To ensure consistency of the data, you can validate values being set at arbitrarily deep keys using `validate` method, that takes an arbitrarily nested key as its argument and a validation block.

```ruby
config.validate(:settings, :base) do |key, value|
  if value.length != 3
    raise TTY::Config::ValidationError, "Currency code needs to be 3 chars long."
  end
end
```

You can assign multiple validations for a given key and each of them will be run in the order they were registered when checking a value.

When setting value all the validations will be run:

```ruby
config.set(:settings, :base, value: "PL")
# raises TTY::Config::ValidationError, "Currency code needs to be 3 chars long."
```

If the value is provided as a proc or a block then the validation will be delayed until the value is actually read:

```ruby
config.set(:settings, :base) { "PL" }
config.fetch(:settings, :base)
# raises TTY::Config::ValidationError, "Currency code needs to be 3 chars long."
```

### 2.12 filename=

By default, **TTY::Config** searches for `config` named configuration file. To change this use `filename=` method without the extension name:

```ruby
config.filename = "investments"
```

Then any supported extensions will be searched for such as `.yml`, `.json` and `.toml`.

### 2.13 extname=

By default ".yml" extension is used to write configuration out to a file but you can change that with `extname=`:

```ruby
config.extname = ".toml"
```

### 2.14 append_path

You need to tell the **TTY::Config** where to search for configuration files. To search multiple paths for a configuration file use `append_path` or `prepend_path` methods.

For example, if you want to search through `/etc` directory first, then user home directory and then current directory do:

```ruby
config.append_path("/etc/")   # look in /etc directory
config.append_path(Dir.home)  # look in user's home directory
config.append_path(Dir.pwd)   # look in current working directory
```

None of these paths are required, but you should provide at least one path if you wish to read a configuration file.

### 2.15 prepend_path

The `prepend_path` allows you to add configuration search paths that should be searched first.

```ruby
config.append_path(Dir.pwd)   # look in current working directory second
config.prepend_path(Dir.home) # look in user's home directory first
```

### 2.16 read

There are two ways for reading configuration files and both use the `read` method. One attempts to guess extension and format of your data, the other allows you to request specific extension and format.

Currently the supported file formats are:

* `yaml` for `.yaml`, `.yml` extensions
* `json` for `.json` extension
* `toml` for `.toml` extension
* `ini`  for `.ini`, `.cnf`, `.conf`, `.cfg`, `.cf extensions`
* `hcl`  for `.hcl` extensions
* `xml`  for `.xml` extension
* `jprops` for `.properties`, `.props`, `.prop` extensions

Calling `read` without any arguments searches through provided locations to find configuration file and reads it. Therefore, you need to specify at least one search path that contains the configuration file together with actual filename. When filename is specified then all known extensions will be tried.

For example, to find file called investments in the current directory do:

```ruby
config.append_path(Dir.pwd)       # look in current working directory
config.filename = "investments"   # file to search for
```

Find and read the configuration file:

```ruby
config.read
```

You can also specify directly the file to read without setting up any search paths or filenames. If you specify a configuration with a known file extension, an appropriate format will be guessed, in this instance `TOML`:

```ruby
config.read("./investments.toml")
```

In cases where you wish to specify a custom file extension, you will need to also specify the file format to use.

For example, if you have a configuration file formatted using `YAML` notation with extension called `.config`, to read it do:

```ruby
config.read("investments.config", format: :yaml)
```

### 2.17 write

By default **TTY::Config**, persists configuration file in the current working directory with a `config.yml` name. However, you can change the default file name by specifying the `filename` and `extension` type:

```ruby
config.filename = "investments"
config.extname = ".toml"
```

Now, by invoking `write` you will persist the current configuration to `investments.toml` file.

```ruby
config.write   # writes "investments.toml" in the current directory
```

To write the current configuration to a file in a custom location, you can specify a direct location path and filename as an argument:

```ruby
config.write("/custom/path/to/investments.toml")
# may raise an error if any of the path directories are missing
```

Alternatively, if the filename doesn't need to change you can specify only a custom path using the `:path` keyword:

```ruby
config.write(path: "/custom/path/to")
# may raise an error if any of the path directories are missing
```

If the `/custom/path/to` doesn't exist an error will be raised. You can set the `:create` option to make any missing directories in the path:

```ruby
config.write("/custom/path/to/investments.toml", create: true)
config.write(path: "/custom/path/to", create: true)
```

When the `investments.toml` file already exists the `TTY::Config::WriteError` error will be raised.

To create a configuration file regardless of whether it exists or not, use `:force` flag:

```ruby
config.write(force: true)
config.write("/custom/path/to/investments.toml", force: true)
config.write(path: "/custom/path/to", force: true)
```

By default, only the current directory is searched. You can specify additional location paths to be searched for already existing configuration to overwrite:

```ruby
config.append_path("/custom/path/to")  # search in "/custom/path/to" for config file
```

By setting the `:create` option to `true`, you can ensure that even when no path is found that has a configuration file, the first location will be used and all missing directories created.

To ensure that a configuration file is written no matter what, use both `:create` and `:force`:

```ruby
config.write(create: true, force: true)
```

### 2.18 exist?

To check if a configuration file exists within the configured search paths use `exist?` method:

```ruby
config.exist? # => true
```

### 2.19 env_prefix=

Given the following variables:

```ruby
ENV["MYTOOL_HOST"] = "127.0.0.1"
ENV["MYTOOL_PORT"] = "7727"
```

You can inform configuration about common prefix using `env_prefix`:

```ruby
config.env_prefix = "mytool"
```

Then set configuration key name to environment variable name:

```ruby
config.set_from_env(:host)
config.set_from_env(:port)
```

And retrieve the value:

```ruby
config.fetch(:host)
# => "127.0.0.1"
config.fetch(:port)
# => "7727"
```

### 2.20 env_separator=

By default, the `_` character is used to separate parts in the environment variable name and it can be changed using the `env_separator=` like so:

```ruby
config.env_separator = "___"
```

Given the following environment variable:

```ruby
ENV["SERVER__PORT"] = "123"
```

Then we can make configuration aware of the above variable name in one of these ways:

```ruby
config.set_from_env(:server, :port)
config.set_from_env("server.port")
````

And retrieve the value:

```ruby
config.fetch(:server, :port)
# => "123"
```

### 2.21 autoload_env

The `autoload_env` method allows you to automatically read environment variables. In most cases you would combine it with [env_prefix=](#219-env_prefix) to only read a subset of variables. When using `autoload_env`, anytime the `fetch` is called a corresponding environment variable will be checked.

For example, given an environment variable `MYTOOL_HOST` set to `localhost`:

```ruby
ENV["MYTOOL_HOST"]=localhost
```

And loading environment variables with a prefix of `MYTOOL`:

```ruby
config.env_prefix = "mytool"
config.autoload_env
```

You can retrieve value with:

```ruby
config.fetch(:host)
# => "localhost"
```

### 2.22 register_marshaller

There are number of built-in marshallers that handle the process of serializing internal configuration from and back into a desired format, for example, a `JSON` string.

Currently supported formats out-of-the-box are: `YAML`, `JSON`, `TOML`, `INI`, `XML`, `HCL` & `Java Properties`.

To create your own marshaller use the `TTY::Config::Marshaller` interface. You need to provide the implementation for the following marshalling methods:

* `marshal`
* `unmarshal`

In addition, you will need to specify the extension types this marshaller will handle using the `extension` method. The method accepts a list of names preceded by a dot:

```ruby
extension ".ext1", ".ext2", ".ext3"
```

Optionally, you can provide a dependency or dependencies that will be lazy loaded if the extension is used. For this use the `dependency` method.

You can either specify dependencies as a list of names:

```ruby
dependency "toml"
dependency "toml", "tomlrb"
```

Or provide dependencies in a block:

```ruby
dependency do
  require "toml"
  require "tomlrb"
end
```

Putting it all together, you can create your own marshaller like so:

```ruby
class MyCustomMarshaller
  include TTY::Config::Marshaller

  dependency "my_dep"

  extension ".ext1", ".ext2"

  def marshal(object)
    MyDep.dump(object)
  end

  def unmarshal(content)
    MyDep.parse(content)
  end
end
```

And then let the configuration know about your marshaller by calling the `register_marshaller`:

```ruby
config.register_marshaller(:my_custom, MyCustomMarshaller)
```

Bear in mind that you can also override the built-in implementation of a marshaller. For example, if you find a better performing Ruby gem for TOML parsing, register your custom marshaller under the `:toml` name like so:

```ruby
config.register_marshaller(:toml, MyTOMLMarshaller)
```

### 2.23 unregister_marshaller

By default, the **TTY::Config** is ready to recognize various extensions. See [2.16 read](#216-read) section for more details. But, you're free to remove the default marshallers from the internal registry with `unregister_marshaller` method.

For example, to remove all the built-in marshallers do:

```ruby
config.unregister_marshaller :yaml, :json, :toml, :ini, :xml, :hcl, :jprops
```

## 3. Examples

### 3.1 Working with env vars

*TTY::Config* fully supports working with environment variables. For example, there are couple of environment variables that your configuration is interested in, which normally would be set in terminal but for the sake of this example we assign them:

```ruby
ENV["MYTOOL_HOST"] = "192.168.1.17"
ENV["MYTOOL_PORT"] = "7727"
```

Then in order to make your configuration aware of the above, you would use [env_prefix=](#219-env_prefix) and [set_from_env](#23-set_from_env):

```ruby
config.env_prefix = "mytool"
config.set_from_env(:host)
config.set_from_env(:port)
```

Or automatically load all prefixed environment variables with [autoload_env](#221-autoload_env):

```ruby
config.env_prefix = "mytool"
config.autoload_env
```

And then retrieve values with [fetch](#24-fetch):

```ruby
config.fetch(:host)
#=> "192.168.1.17"
config.fetch(:port)
# => "7727"
```

### 3.2 Working with optparse

This is an example of combining `tty-config` with `optparse` stdlib.

Let's assume you want to create a command line tool that among many options accepts `--host|-h` and `--port|-p` flags. In addition, these flags will take precedence over the options specified in the configuration file.

First, you need to parse the flags and store results away in options hash:

```ruby
require "optparse"

options = {}

option_parser = OptionParser.new do |opts|
  opts.on("-h", "--host HOSTNAME_OR_IP", "Hostname or IP Adress") do |h|
    options[:host] = h
  end
  opts.on("-p", "--port PORT", "Port of application", Integer) do |p|
    options[:port] = p
  end
  opts.on("-c", "--config FILE",
         "Read config values from file (defaults: ./config.yml, ~/.config.yml") do |c|
    options[:config_file_path] = c
  end
  ...
end

option_parser.parse!
```

Then, you create a configuration instance:

```ruby
config = TTY::Config.new
```

And setup config filename:

```ruby
config_filename = options[:config_file_path] || "config.yml"
```

As well as add configuration file locations to search in:

```ruby
config.append_path Dir.pwd
config.append_path Dir.home
```

Once config is initialized, you can read the configuration from a config file:

```ruby
begin
  config.read(config_filename)  # by default the "config.yml" is read
rescue TTY::Config::ReadError => read_error
  STDERR.puts "\nNo configuration file found:"
  STDERR.puts read_error
end
```

Then merge options passed as arguments with those stored in a configuration file:

```ruby
config.merge(options)
```

Provide optional validation to ensure both host and port are configured:

```ruby
if !config.fetch(:host) || !config.fetch(:port)
  STDERR.puts "Host and port have to be specified (call with --help for help)."
  exit 1
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-config. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TTY::Config project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/tty-config/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2018 Piotr Murach. See LICENSE for further details.
