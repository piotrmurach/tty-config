# frozen_string_literal: true
#
RSpec.describe TTY::Config, "#validate" do
  let(:validation) {
    -> (key, value) do
      unless value.is_a?(Integer)
        raise TTY::Config::ValidationError, "Failed validation for key=#{key}"
      end
    end
  }

  it "validates string value successfully" do
    config = TTY::Config.new
    config.validate(:foo, :bar, &validation)
    config.set(:foo, :bar, value: 2)
    expect(config.fetch(:foo, :bar)).to eq(2)
  end

  it "validates a proc value successfully" do
    config = TTY::Config.new
    config.validate(:foo, :bar, &validation)
    config.set(:foo, :bar, value: -> { 2 })
    expect(config.fetch(:foo, :bar)).to eq(2)
  end

  it "validates a block value successfully" do
    config = TTY::Config.new
    config.validate(:foo, :bar, &validation)
    config.set(:foo, :bar) { 2 }
    expect(config.fetch(:foo, :bar)).to eq(2)
  end

  it "raises an error when set value fails validation" do
    config = TTY::Config.new
    config.validate(:foo, :bar, &validation)
    expect {
      config.set(:foo, :bar, value: "2")
    }.to raise_error(TTY::Config::ValidationError,
                    "Failed validation for key=foo.bar")
  end

  it "raises an error when set value as a proc fails validation" do
    config = TTY::Config.new
    config.validate(:foo, :bar, &validation)
    config.set(:foo, :bar, value: -> { "2" })
    expect {
      config.fetch(:foo, :bar)
    }.to raise_error(TTY::Config::ValidationError,
                     "Failed validation for key=foo.bar")
  end

  it "raises an eror when ste value as a block fails validation" do
    config = TTY::Config.new
    config.validate(:foo, :bar, &validation)
    config.set(:foo, :bar) { "2" }
    expect {
      config.fetch(:foo, :bar)
    }.to raise_error(TTY::Config::ValidationError,
                     "Failed validation for key=foo.bar")
  end

  it "applies multiple validations" do
    config = TTY::Config.new
    config.validate(:foo, :bar) do |key, val|
      unless val.is_a?(Integer)
        raise TTY::Config::ValidationError, "Not integer"
      end
    end
    config.validate(:foo, :bar) do |key, val|
      unless val > 100
        raise TTY::Config::ValidationError , "Value out of range"
      end
    end
    expect {
      config.set(:foo, :bar, value: 99)
    }.to raise_error(TTY::Config::ValidationError, "Value out of range")
  end
end
