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
      TTY::Config::Marshallers::XMLMarshaller,
      TTY::Config::Marshallers::HCLMarshaller,
      TTY::Config::Marshallers::JavaPropsMarshaller,
      CustomMarshaller
    ])

    config.unregister_marshaller :json
    config.unregister_marshaller :yaml, :toml, :ini, :xml, :hcl, :jprops

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
      TTY::Config::Marshallers::XMLMarshaller,
      TTY::Config::Marshallers::HCLMarshaller,
      TTY::Config::Marshallers::JavaPropsMarshaller
    ])
  end

  it "inherits from existing marshaller" do
    stub_const("CustomYAMLMarshaller",
               Class.new(TTY::Config::Marshallers::YAMLMarshaller) do
                 def marshal(data)
                   YAML.safe_load(data, aliases: true)
                 end
               end)

    config = TTY::Config.new
    config.register_marshaller :yaml, CustomYAMLMarshaller

    expect(config.marshallers).to eq([
      CustomYAMLMarshaller,
      TTY::Config::Marshallers::JSONMarshaller,
      TTY::Config::Marshallers::TOMLMarshaller,
      TTY::Config::Marshallers::INIMarshaller,
      TTY::Config::Marshallers::XMLMarshaller,
      TTY::Config::Marshallers::HCLMarshaller,
      TTY::Config::Marshallers::JavaPropsMarshaller
    ])
    expect(CustomYAMLMarshaller.ext).to eq(%w[.yaml .yml])
    expect(CustomYAMLMarshaller.dep_name).to eq(%w[yaml])
  end
end
