# frozen_string_literal: true

RSpec.describe TTY::Config, "#extensions" do
  it "provides available extensions" do
    config = TTY::Config.new

    expect(config.extensions).to eq([
      ".yaml", ".yml",
      ".json",
      ".toml",
      ".ini", ".cnf", ".conf", ".cfg", ".cf",
      ""])
  end

  it "includes newly registered extensions" do
    Marshaller = Class.new(TTY::Config::Marshallers::Abstract) do
      dependency "mydep"

      extension ".ext"

      def marshal(data); end

      def unmarshal(file); end
    end

    config = TTY::Config.new

    config.register :custom, Marshaller

    expect(config.extensions).to eq([
      ".yaml", ".yml",
      ".json",
      ".toml",
      ".ini", ".cnf", ".conf", ".cfg", ".cf",
      ".ext",
      ""])
  end
end
