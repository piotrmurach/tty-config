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
    expect(config.fetch(:foo, default: -> { -> { :bar } })).to eq(:bar)
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

  context "when environment and settings conflict" do
    before :each do
      ENV.update({ "SETTINGS_BASE" => "CAD" })
      @config = TTY::Config.new do |config|
        config.read fixtures_path("investments.yml")
        config.set_from_env(:settings, :base)
      end
      @default = @config.preferred
  end

    context "and settings are preferred (default)" do
      before :each do
        @config.prefer @default
      end

      it "uses the value from settings" do
        expect(@config.fetch(:settings, :base)).to eq("USD")
      end

      it "uses the value from environment on demand" do
        expect(@config.fetch(:settings, :base, prefer: :environment)).to eq("CAD")
      end
    end

    context "and environment is preferred" do
      before :each do
        @config.prefer :environment
      end

      it "uses the value from environment" do
        expect(@config.fetch(:settings, :base)).to eq("CAD")
      end

      it "uses the value from settings on demand" do
        expect(@config.fetch(:settings, :base, prefer: :settings)).to eq("USD")
      end
    end
  end
end
