# TTY::Config

> Define, read and write any Ruby app configurations with a penchant for terminal clients.

**TTY::Config** provides app configuration component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-config'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-config

## Usage

Initialize the configuration and provide the name:

```ruby
config = TTY::Config.new
config.filename = 'investments'
```

then configure values for different nested keys with `set` and `append`:

```ruby
config.set('settings', 'base', value: 'USD')
config.set('settings', 'color', value: true)
config.set('coins', value: ['BTC'])

config.append('ETH', 'TRX', 'DASH', to: 'coins')
```

get any value by using `fetch`:

```ruby
config.fetch('settings', 'base')
# => 'USD'

config.fetch('coins')
# => ['BTC', 'ETH', 'TRX', 'DASH']
```

and `write` configration out to `investments.yml`:

```ruby
config.write
# =>
# ---
# settings:
#   base: USD
#   color: true
# conins:
#  - BTC
#  - ETH
#  - TRX
#  - DASH
```

and then to read and `investments.yml` file, you need to provide the locations to search in:

```ruby
config.append_path Dir.pwd
config.append_path Dir.home
```

Finally, read in configuration back again:

```ruby
config.read
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tty-config. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Tty::Config project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/tty-config/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2018 Piotr Murach. See LICENSE for further details.
