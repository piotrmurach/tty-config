# frozen_string_literal: true

RSpec.describe TTY::Config, '#alias_setting' do
  it "aliases setting key" do
    config = TTY::Config.new
    config.set :foo, value: :baz

    config.alias_setting :foo, to: :bar

    expect(config.fetch(:foo)).to eq(:baz)
    expect(config.fetch(:bar)).to eq(:baz)
  end

  it "aliases nested key to flat key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz) { 12 }

    config.alias_setting(:foo, :bar, :baz, to: :flat_foo)

    expect(config.fetch(:foo, :bar, :baz)).to eq(12)
    expect(config.fetch(:flat_foo)).to eq(12)
  end

  it "aliases nested key as a string to flat key" do
    config = TTY::Config.new
    config.set('foo.bar.baz') { 12 }

    config.alias_setting(:foo, :bar, :baz, to: :flat_foo)

    expect(config.fetch(:foo, :bar, :baz)).to eq(12)
    expect(config.fetch(:flat_foo)).to eq(12)
  end

  it "aliases nested key to nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz) { 12 }

    config.alias_setting(:foo, :bar, :baz, to: [:bee, :bop])

    expect(config.fetch(:foo, :bar, :baz)).to eq(12)
    expect(config.fetch(:bee, :bop)).to eq(12)
  end

  it "fails to alias to already existing key" do
    config = TTY::Config.new
    config.set(:foo, value: 1)
    config.set(:bar, value: 2)

    expect {
      config.alias_setting(:foo, to: :bar)
    }.to raise_error(ArgumentError, "Setting already exists with an alias ':bar'")
  end

  it "fails to alias to already existing key" do
    config = TTY::Config.new
    config.set(:foo, :bar, value: 1)
    config.set(:baz, :woo, value: 2)

    expect {
      config.alias_setting(:foo, :bar, to: [:baz, :woo])
    }.to raise_error(ArgumentError, "Setting already exists with an alias ':baz, :woo'")
  end

  it "fails to alias to matching key" do
    config = TTY::Config.new
    config.set(:foo, :bar, value: 1)

    expect {
      config.alias_setting(:foo, :bar, to: [:foo, :bar])
    }.to raise_error(ArgumentError, "Alias matches setting key")
  end
end
