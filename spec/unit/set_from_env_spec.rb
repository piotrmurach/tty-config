# frozen_string_literal: true

RSpec.describe TTY::Config, '#set_from_env' do
  it "fetches env variables" do
    allow(ENV).to receive(:[]).with('HOST').and_return('localhost')
    allow(ENV).to receive(:[]).with('PORT').and_return('7727')

    config = TTY::Config.new
    config.set_from_env(:host)
    config.set_from_env(:port)

    expect(config.fetch(:host)).to eq('localhost')
    expect(config.fetch(:port)).to eq('7727')
  end

  it "fetches multipart env variables" do
    allow(ENV).to receive(:[]).with('FOO_BAR_BAZ').and_return('1')
    config = TTY::Config.new
    config.set_from_env(:foo_bar_baz)

    expect(config.fetch(:foo_bar_baz)).to eq('1')
  end

  it "prefixes env variables" do
    allow(ENV).to receive(:[]).with('MYTOOL_HOST').and_return('localhost')
    allow(ENV).to receive(:[]).with('MYTOOL_PORT').and_return('7727')

    config = TTY::Config.new
    config.env_prefix = 'mytool'
    config.set_from_env(:host)
    config.set_from_env(:port)

    expect(config.fetch(:host)).to eq('localhost')
    expect(config.fetch(:port)).to eq('7727')
  end

  it "allows to set env vars for deeply nested keys" do
    allow(ENV).to receive(:[]).with('HOST').and_return('localhost')

    config = TTY::Config.new
    config.set_from_env(:foo, :bar) { "HOST" }

    expect(config.fetch(:foo, :bar)).to eq('localhost')
  end

  it "allows to set env vars with prefix for deeply nested keys" do
    allow(ENV).to receive(:[]).with('MYTOOL_HOST').and_return('localhost')

    config = TTY::Config.new
    config.env_prefix = 'mytool'
    config.set_from_env(:foo, :bar) { "HOST" }

    expect(config.fetch(:foo, :bar)).to eq('localhost')
  end

  it "allows to set env vars for deeply nested keys as string" do
    allow(ENV).to receive(:[]).with('HOST').and_return('localhost')

    config = TTY::Config.new
    config.set_from_env('foo.bar') { "HOST" }

    expect(config.fetch(:foo, :bar)).to eq('localhost')
  end

  it "fails if env var is not specified for deeply nested keys as string" do
    config = TTY::Config.new
    expect {
      config.set_from_env('foo.bar')
    }.to raise_error(ArgumentError, 'Need to set env var in block')
  end

  it "fails if env var is not specified for deeply nested keys" do
    config = TTY::Config.new
    expect {
      config.set_from_env(:foo, :bar)
    }.to raise_error(ArgumentError, 'Need to set env var in block')
  end
end
