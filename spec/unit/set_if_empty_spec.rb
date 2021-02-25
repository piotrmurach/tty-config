# frozen_string_literal: true

RSpec.describe TTY::Config, "#set_if_empty" do
  it "sets value for empty" do
    config = TTY::Config.new
    config.set_if_empty(:foo, value: :bar)
    expect(config.fetch(:foo)).to eq(:bar)
  end

  it "sets value for empty deeply nested key" do
    config = TTY::Config.new({ foo: {} })
    config.set_if_empty(:foo, :bar, :baz, value: 2)
    expect(config.fetch(:foo, :bar, :baz)).to eq(2)
  end

  it "sets value for a nested key as string delimited by dot" do
    config = TTY::Config.new
    config.set_if_empty("foo.bar.baz", value: 1)
    expect(config.fetch("foo", "bar", "baz")).to eq(1)
  end

  it "doesn't override existing value" do
    config = TTY::Config.new
    config.set(:foo, value: 1)
    config.set_if_empty(:foo, value: 2)
    expect(config.fetch(:foo)).to eq(1)
  end
end
