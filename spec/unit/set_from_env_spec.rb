# frozen_string_literal: true

RSpec.describe TTY::Config, "#set_from_env" do
  it "sets env variables without any separators" do
    allow(ENV).to receive(:[]).with("HOST").and_return("localhost")
    allow(ENV).to receive(:[]).with("PORT").and_return("7727")

    config = TTY::Config.new
    config.set_from_env(:host)
    config.set_from_env(:port)

    expect(config.fetch(:host)).to eq("localhost")
    expect(config.fetch(:port)).to eq("7727")
  end

  it "sets non-existent env variables" do
    allow(ENV).to receive(:[]).with(any_args).and_return(nil)
    config = TTY::Config.new
    config.set_from_env(:host)
    config.set_from_env(:port)

    expect(config.fetch(:host)).to eq(nil)
    expect(config.fetch(:port)).to eq(nil)
  end

  it "sets underscore separated env variable with a single symbol key" do
    allow(ENV).to receive(:[]).with("FOO_BAR_BAZ").and_return("1")
    config = TTY::Config.new
    config.set_from_env(:foo_bar_baz)

    expect(config.fetch(:foo_bar_baz)).to eq("1")
  end

  it "sets underscore separated env variable with a nested key" do
    allow(ENV).to receive(:[]).with("FOO_BAR_BAZ").and_return("1")
    config = TTY::Config.new
    config.set_from_env(:foo, :bar, :baz)

    expect(config.fetch(:foo, :bar, :baz)).to eq("1")
  end

  it "sets underscore separated env variable with a dot-delimited string key" do
    allow(ENV).to receive(:[]).with("FOO_BAR_BAZ").and_return("1")
    config = TTY::Config.new
    config.set_from_env("foo.bar.baz")

    expect(config.fetch(:foo, :bar, :baz)).to eq("1")
  end

  it "sets env variables with a common prefix" do
    allow(ENV).to receive(:[]).with("MYTOOL_HOST").and_return("localhost")
    allow(ENV).to receive(:[]).with("MYTOOL_PORT").and_return("7727")

    config = TTY::Config.new
    config.env_prefix = "mytool"
    config.set_from_env(:host)
    config.set_from_env(:port)

    expect(config.fetch(:host)).to eq("localhost")
    expect(config.fetch(:port)).to eq("7727")
  end

  it "sets env variables with a common prefix and a key alias" do
    allow(ENV).to receive(:[]).with("MYTOOL_HOST").and_return("localhost")
    allow(ENV).to receive(:[]).with("MYTOOL_PORT").and_return("7727")

    config = TTY::Config.new
    config.env_prefix = "mytool"
    config.set_from_env(:foo) { "HOST" }
    config.set_from_env(:bar) { "PORT" }

    expect(config.fetch(:foo)).to eq("localhost")
    expect(config.fetch(:bar)).to eq("7727")
  end

  it "sets env variable with a deeply nested alias key" do
    allow(ENV).to receive(:[]).with("HOST").and_return("localhost")

    config = TTY::Config.new
    config.set_from_env(:foo, :bar) { "HOST" }

    expect(config.fetch(:foo, :bar)).to eq("localhost")
  end

  it "sets env variable with a deeply nested alias key as a string" do
    allow(ENV).to receive(:[]).with("HOST").and_return("localhost")

    config = TTY::Config.new
    config.set_from_env("foo.bar") { "HOST" }

    expect(config.fetch(:foo, :bar)).to eq("localhost")
  end

  it "sets env variable with a prefix and a deeply nested key alias" do
    allow(ENV).to receive(:[]).with("MYTOOL_HOST").and_return("localhost")

    config = TTY::Config.new
    config.env_prefix = "mytool"
    config.set_from_env(:foo, :bar) { "HOST" }

    expect(config.fetch(:foo, :bar)).to eq("localhost")
  end

  it "sets env variable with a custom separator" do
    allow(ENV).to receive(:[]).with("FOO-BAR-BAZ").and_return("2")

    config = TTY::Config.new
    config.env_separator = "-"
    config.set_from_env(:foo, :bar, :baz)

    expect(config.fetch(:foo, :bar, :baz)).to eq("2")
  end

  it "sets env variable with a custom separator and prefix" do
    allow(ENV).to receive(:[]).with("MYTOOL__FOO__BAR").and_return("localhost")

    config = TTY::Config.new
    config.env_prefix = "mytool"
    config.env_separator = "__"
    config.set_from_env(:foo, :bar)

    expect(config.fetch(:foo, :bar)).to eq("localhost")
  end

  it "sets env variable with a custom separator, a prefix and a key alias" do
    allow(ENV).to receive(:[]).with("MYTOOL__HOST").and_return("localhost")

    config = TTY::Config.new
    config.env_prefix = "mytool"
    config.env_separator = "__"
    config.set_from_env(:foo, :bar) { "HOST" }

    expect(config.fetch(:foo, :bar)).to eq("localhost")
  end
end
