# frozen_string_literal: true

RSpec.describe TTY::Config, "#read" do
  it "read from an empty file" do
    file = fixtures_path("empty.yml")
    config = TTY::Config.new

    config.read(file)

    expect(config.to_hash).to eq({})
  end

  it "can modify content before parsing" do
    file = fixtures_path("empty.yml")
    config = TTY::Config.new

    config.read(file) do |contents|
      contents.concat <<~EOF
      ---
      appended: true
      EOF
    end

    expect(config.to_hash).to eq({ "appended" => true })
  end

  it "reads from a specified file" do
    file = fixtures_path("investments.yml")
    config = TTY::Config.new

    config.read(file)

    expect(config.fetch(:settings, :base)).to eq("USD")
  end

  it "searched for a file to read from" do
    config = TTY::Config.new
    config.filename = "investments"
    config.append_path(fixtures_path)

    config.read

    expect(config.fetch(:settings, :base)).to eq("USD")
  end

  it "reads from a specified file and merges with defaults" do
    file = fixtures_path("investments.yml")
    config = TTY::Config.new
    config.set(:settings, :base, value: "EUR")
    config.set(:settings, :top, value: 50)

    config.read(file)

    expect(config.fetch(:settings, :base)).to eq("USD")
    expect(config.fetch(:settings, :exchange)).to eq("CCCAGG")
    expect(config.fetch(:settings, :top)).to eq(50)
  end

  it "reads a json format" do
    file = fixtures_path("investments.json")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("investments")
    expect(config.extname).to eq(".json")
    expect(config.fetch(:settings, :base)).to eq("USD")
    expect(config.fetch(:coins)).to eq(%w[BTC ETH TRX DASH])
  end

  it "reads json file without any settings" do
    file = fixtures_path("empty.json")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("empty")
    expect(config.extname).to eq(".json")
    expect(config.to_hash).to eq({})
  end

  it "reads a toml format" do
    file = fixtures_path("investments.toml")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("investments")
    expect(config.extname).to eq(".toml")
    expect(config.fetch(:settings, :base)).to eq("USD")
    expect(config.fetch(:coins)).to eq(%w[BTC ETH TRX DASH])
  end

  it "reads empty file with toml extension" do
    file = fixtures_path("empty.toml")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("empty")
    expect(config.extname).to eq(".toml")
    expect(config.to_hash).to eq({})
  end

  it "reads an ini format" do
    file = fixtures_path("investments.ini")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("investments")
    expect(config.extname).to eq(".ini")
    expect(config.fetch(:settings, :base)).to eq("USD")
    expect(config.fetch(:coins).split(",")).to eq(%w[BTC ETH TRX DASH])
  end

  it "reads empty file with ini extension" do
    file = fixtures_path("empty.ini")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("empty")
    expect(config.extname).to eq(".ini")
    expect(config.to_hash).to eq({})
  end

  it "reads an hcl format" do
    file = fixtures_path("investments.hcl")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("investments")
    expect(config.extname).to eq(".hcl")
    expect(config.fetch(:settings, :base)).to eq("USD")
    expect(config.fetch(:coins)).to eq(%w[BTC ETH TRX DASH])
  end

  it "reads empty file with hcl extension" do
    file = fixtures_path("empty.hcl")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("empty")
    expect(config.extname).to eq(".hcl")
    expect(config.to_hash).to eq({})
  end

  it "reads a java properties format" do
    file = fixtures_path("investments.props")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("investments")
    expect(config.extname).to eq(".props")
    expect(config.fetch(:base)).to eq("USD")
    expect(config.fetch(:coins).split(",")).to eq(%w[BTC ETH TRX DASH])
  end

  it "reads empty file with java properties extension" do
    file = fixtures_path("empty.props")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("empty")
    expect(config.extname).to eq(".props")
    expect(config.to_hash).to eq({})
  end

  it "reads a file in an xml format" do
    file = fixtures_path("investments.xml")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("investments")
    expect(config.extname).to eq(".xml")
    expect(config.fetch(:settings, :base)).to eq("USD")
    expect(config.fetch(:settings, :exchange)).to eq("CCCAGG")
    expect(config.fetch(:coins)).to eq(%w[BTC ETH TRX DASH])
  end

  it "reads an empty file with an xml extension" do
    file = fixtures_path("empty.xml")
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq("empty")
    expect(config.extname).to eq(".xml")
    expect(config.to_hash).to eq({})
  end

  it "reads custom format" do
    file = fixtures_path(".env")
    config = TTY::Config.new

    config.read(file, format: :ini)

    expect(config.filename).to eq(".env")
    expect(config.extname).to eq("")
    expect(config.fetch(:settings, :base)).to eq("USD")
    expect(config.fetch(:coins).split(",")).to eq(%w[BTC ETH TRX DASH])
  end

  it "fails to find a file to read" do
    config = TTY::Config.new
    expect {
      config.read
    }.to raise_error(TTY::Config::ReadError,
                     "No file found to read configuration from!")
  end

  it "fails to read a file" do
    config = TTY::Config.new
    file = fixtures_path("unknown.yml")

    expect {
      config.read(file)
    }.to raise_error(TTY::Config::ReadError,
                     "Configuration file `#{file}` does not exist!")
  end

  it "fails to load dependency for reading file format" do
    allow(TTY::Config::Marshallers::YAMLMarshaller)
      .to receive(:require).with("yaml").and_raise(LoadError)

    config = TTY::Config.new
    file = fixtures_path("investments.yml")

    expect {
      config.read(file)
    }.to raise_error(TTY::Config::DependencyLoadError,
                     /The dependency `yaml` is missing/)
  end
end
