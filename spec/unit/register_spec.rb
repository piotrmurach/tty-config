# frozen_string_literal: true

RSpec.describe TTY::Config, "#register" do
  it "registers a custom marshaller" do
    stub_const("CustomMarshaller", Class.new(TTY::Config::Marshallers::Abstract) do
      dependency "yaml"

      extension ".yml"

      def marshal(data); end

      def unmarshal(file); end
    end)

    config = TTY::Config.new
    expect(config.registered?(:custom)).to eq(false)

    config.register :custom, CustomMarshaller
    expect(config.registered?(:custom)).to eq(true)
    expect(config.marshallers).to eq([
      TTY::Config::Marshallers::YAMLMarshaller,
      TTY::Config::Marshallers::JSONMarshaller,
      TTY::Config::Marshallers::TOMLMarshaller,
      TTY::Config::Marshallers::INIMarshaller,
      TTY::Config::Marshallers::HCLMarshaller,
      CustomMarshaller])

    config.unregister :json
    config.unregister :yaml, :toml, :ini, :hcl

    expect(config.marshallers).to eq([CustomMarshaller])
  end

  it "overrides existing marshaller" do
    stub_const("CustomMarshaller", Class.new(TTY::Config::Marshallers::Abstract) do
      dependency "mydep"

      extension ".ext"

      def marshal(data); end

      def unmarshal(file); end
    end)

    config = TTY::Config.new
    config.register :yaml, CustomMarshaller

    expect(config.marshallers).to eq([
      CustomMarshaller,
      TTY::Config::Marshallers::JSONMarshaller,
      TTY::Config::Marshallers::TOMLMarshaller,
      TTY::Config::Marshallers::INIMarshaller,
      TTY::Config::Marshallers::HCLMarshaller
    ])
  end
end
