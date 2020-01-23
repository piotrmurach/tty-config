# frozen_string_literal: true

RSpec.describe TTY::Config, "#register" do
  it "registers a custom marshaller" do
    stub_const("Marshaller", Class.new(TTY::Config::Marshallers::Abstract) do
      dependency "yaml"

      extension ".yml"

      def marshal(data); end

      def unmarshal(file); end
    end)

    config = TTY::Config.new
    expect(config.registered?(:custom)).to eq(false)

    config.register :custom, Marshaller
    expect(config.registered?(:custom)).to eq(true)
    expect(config.marshallers).to eq([
      TTY::Config::Marshallers::YAMLMarshaller,
      TTY::Config::Marshallers::JSONMarshaller,
      TTY::Config::Marshallers::TOMLMarshaller,
      TTY::Config::Marshallers::INIMarshaller,
      TTY::Config::Marshallers::HCLMarshaller,
      Marshaller])

    config.unregister :json
    config.unregister :yaml, :toml, :ini, :hcl

    expect(config.marshallers).to eq([Marshaller])
  end

  it "overrides existing marshaller" do
    stub_const("Marshaller", Class.new(TTY::Config::Marshallers::Abstract) do
      dependency "mydep"

      extension ".ext"

      def marshal(data); end

      def unmarshal(file); end
    end)

    config = TTY::Config.new
    config.register :yaml, Marshaller

    expect(config.marshallers).to eq([
      Marshaller,
      TTY::Config::Marshallers::JSONMarshaller,
      TTY::Config::Marshallers::TOMLMarshaller,
      TTY::Config::Marshallers::INIMarshaller,
      TTY::Config::Marshallers::HCLMarshaller
    ])
  end
end
