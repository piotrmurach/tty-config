# frozen_string_literal: true

RSpec.describe TTY::Config, "#extensions" do
  it "provides available extensions" do
    config = TTY::Config.new

    expect(config.extensions).to eq([
      ".yaml", ".yml",
      ".json",
      ".toml",
      ".ini", ".cnf", ".conf", ".cfg", ".cf",
      ".xml",
      ".hcl",
      ".properties", ".props", ".prop",
      ""
    ])
  end

  it "includes newly registered extensions" do
    stub_const("CustomMarshaller", Class.new do
      include TTY::Config::Marshaller

      dependency "mydep"

      extension ".ext"

      def marshal(data); end

      def unmarshal(file); end
    end)

    config = TTY::Config.new

    config.register_marshaller :custom, CustomMarshaller

    expect(config.extensions).to eq([
      ".yaml", ".yml",
      ".json",
      ".toml",
      ".ini", ".cnf", ".conf", ".cfg", ".cf",
      ".xml",
      ".hcl",
      ".properties", ".props", ".prop",
      ".ext",
      ""
    ])
  end
end
