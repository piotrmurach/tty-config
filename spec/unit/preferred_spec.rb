# frozen_string_literal: true

RSpec.describe TTY::Config, "#preferred" do
  it "prefers settings over environment by default" do
    config = TTY::Config.new
    expect(config.preferred).to eq(:settings)
  end

  it "sets a preferred source" do
    config = TTY::Config.new
    config.preferred = :environment

    expect(config.preferred).to eq(:environment)
  end

  it "sets a preferred source in a nicer way" do
    config = TTY::Config.new
    config.prefer :environment

    expect(config.preferred).to eq(:environment)
  end

  it "accepts aliases for settings" do
    config = TTY::Config.new

    %i[settings configuration config file files].each do |variant|
      config.preferred = variant
      expect(config.preferred).to eq(:settings)
    end
  end

  it "accepts aliases for environment" do
    config = TTY::Config.new

    %i[environment env ENV].each do |variant|
      config.preferred = variant
      expect(config.preferred).to eq(:environment)
    end
  end

  it "does not accept unknown source names" do
    config = TTY::Config.new
    expect {
      config.preferred = :invalid
    }.to raise_error(TTY::Config::UnsupportedSource,
                     /Preferred Source `invalid` is not supported./)
  end
end