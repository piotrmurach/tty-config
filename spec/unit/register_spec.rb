# frozen_string_literal: true

RSpec.describe TTY::Config, "#register_marshaller" do
  it "registers a custom marshaller" do
    stub_const("CustomMarshaller", Class.new do
      include TTY::Config::Marshaller

      dependency "yaml"

      extension ".yml"

      def marshal(data); end

      def unmarshal(file); end
    end)

    config = TTY::Config.new
    expect(config.registered_marshaller?(:custom)).to eq(false)

    config.register_marshaller :custom, CustomMarshaller
    expect(config.registered_marshaller?(:custom)).to eq(true)
    expect(config.marshallers).to eq([
      TTY::Config::Marshallers::YAMLMarshaller,
      TTY::Config::Marshallers::JSONMarshaller,
      TTY::Config::Marshallers::TOMLMarshaller,
      TTY::Config::Marshallers::INIMarshaller,
      TTY::Config::Marshallers::HCLMarshaller,
      CustomMarshaller])

    config.unregister_marshaller :json
    config.unregister_marshaller :yaml, :toml, :ini, :hcl

    expect(config.marshallers).to eq([CustomMarshaller])
  end

  it "overrides existing marshaller" do
    stub_const("CustomMarshaller", Class.new do
      include TTY::Config::Marshaller

      dependency "mydep"

      extension ".ext"

      def marshal(data); end

      def unmarshal(file); end
    end)

    config = TTY::Config.new
    config.register_marshaller :yaml, CustomMarshaller

    expect(config.marshallers).to eq([
      CustomMarshaller,
      TTY::Config::Marshallers::JSONMarshaller,
      TTY::Config::Marshallers::TOMLMarshaller,
      TTY::Config::Marshallers::INIMarshaller,
      TTY::Config::Marshallers::HCLMarshaller
    ])
  end
end
