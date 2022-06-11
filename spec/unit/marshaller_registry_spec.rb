# frozen_string_literal: true

RSpec.describe TTY::Config::MarshallerRegistry do
  it "initializes registry" do
    registry = TTY::Config::MarshallerRegistry.new

    expect(registry.names).to eq([])
    expect(registry.objects).to eq([])
    expect(registry.exts).to eq([])
  end

  it "accepts initial mappings" do
    mappings = {
      yaml: TTY::Config::Marshallers::YAMLMarshaller,
      json: TTY::Config::Marshallers::JSONMarshaller
    }
    registry = TTY::Config::MarshallerRegistry.new(mappings)

    expect(registry.names).to eq(%i[yaml json])
    expect(registry.objects).to eq(mappings.values)
    expect(registry.exts).to eq(%w[.yaml .yml .json])
  end

  it "registers a marshaller" do
    registry = TTY::Config::MarshallerRegistry.new

    registry.register :yaml, TTY::Config::Marshallers::YAMLMarshaller

    expect(registry.names).to eq(%i[yaml])
    expect(registry.objects).to eq([TTY::Config::Marshallers::YAMLMarshaller])
    expect(registry.exts).to eq(%w[.yaml .yml])
  end

  it "checks if marshialler is registered" do
    mappings = {
      yaml: TTY::Config::Marshallers::YAMLMarshaller,
      json: TTY::Config::Marshallers::JSONMarshaller
    }
    registry = TTY::Config::MarshallerRegistry.new(mappings)

    expect(registry.registered?(:json)).to eq(true)
    expect(registry.registered?(mappings[:yaml])).to eq(true)
    expect(registry.registered?(:toml)).to eq(false)
  end

  it "unregisterse a marshaller" do
    mappings = {
      yaml: TTY::Config::Marshallers::YAMLMarshaller,
      json: TTY::Config::Marshallers::JSONMarshaller
    }
    registry = TTY::Config::MarshallerRegistry.new(mappings)

    registry.unregister :json

    expect(registry.names).to eq(%i[yaml])
    expect(registry.objects).to eq([mappings[:yaml]])
    expect(registry.exts).to eq(%w[.yaml .yml])
  end
end
