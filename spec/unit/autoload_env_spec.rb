# frozen_string_literal: true

RSpec.describe TTY::Config, "#autoload_env" do
  it "autoloads env variables" do
    allow(ENV).to receive(:[]).with("HOST").and_return("localhost")
    config = TTY::Config.new
    expect(config.fetch(:host)).to eq(nil)

    config.autoload_env

    expect(config.fetch(:host)).to eq("localhost")
  end

  it "autoloads env variables with prefix" do
    allow(ENV).to receive(:[]).with("MYTOOL_HOST").and_return("localhost")
    config = TTY::Config.new
    config.env_prefix = "mytool"

    expect(config.fetch(:host)).to eq(nil)

    config.autoload_env

    expect(config.fetch(:host)).to eq("localhost")
  end

  it "prioritises set over env vars" do
    allow(ENV).to receive(:[]).with("HOST").and_return("localhost")
    config = TTY::Config.new
    config.autoload_env

    config.set(:host, value: "myhost")

    expect(config.fetch(:host)).to eq("myhost")
  end

  it "prioritises env vars over defaults when a keyword" do
    allow(ENV).to receive(:[]).with("PORT").and_return("7727")
    config = TTY::Config.new

    config.autoload_env

    expect(config.fetch(:port, default: "3000")).to eq("7727")
  end

  it "prioritises env vars over defaults when block" do
    allow(ENV).to receive(:[]).with("PORT").and_return("7727")
    config = TTY::Config.new

    config.autoload_env

    expect(config.fetch(:port) {"3000" }).to eq("7727")
  end

  it "prioritises present configuration over env vars" do
    allow(ENV).to receive(:[]).with("PORT").and_return("7727")
    config = TTY::Config.new(port: "3000")

    config.autoload_env

    expect(config.fetch(:port)).to eq("3000")
  end
end
