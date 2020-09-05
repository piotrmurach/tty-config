# frozen_string_literal: true

RSpec.describe TTY::Config do
  it "fetches default if no value" do
    config = TTY::Config.new
    expect(config.fetch(:foo, default: :bar)).to eq(:bar)
  end

  it "fetches default proc value" do
    config = TTY::Config.new
    expect(config.fetch(:foo, default: -> { :bar })).to eq(:bar)
  end

  it "fetches deeply nested proc value" do
    config = TTY::Config.new
    expect(config.fetch(:foo, default: -> { -> { :bar }})).to eq(:bar)
  end

  it "fetches default as block" do
    config = TTY::Config.new
    expect(config.fetch(:foo) { :bar }).to eq(:bar)
  end

  it "fetches default as block for deeply nested missing key" do
    config = TTY::Config.new
    expect(config.fetch(:foo, :bar, :baz) { 2 }).to eq(2)
  end

  it "fetches value for deeply nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz, value: 2)
    expect(config.fetch(:foo, :bar, :baz)).to eq(2)
  end

  it "fetches value as string delimited by . for deeply nested key" do
    config = TTY::Config.new
    config.set("foo", "bar", "baz") { 2 }
    expect(config.fetch("foo.bar.baz")).to eq(2)
  end

  it "fetches key with indifferent access" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz, value: 2)

    expect(config.fetch("foo", :bar, "baz")).to eq(2)
  end
end
