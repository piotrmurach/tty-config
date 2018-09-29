RSpec.describe TTY::Config, '#read' do
  it "reads from a specified file" do
    file = fixtures_path('investments.yml')
    config = TTY::Config.new

    config.read(file)

    expect(config.fetch(:settings, :base)).to eq('USD')
  end

  it "searched for a file to read from" do
    config = TTY::Config.new
    config.filename = 'investments'
    config.append_path(fixtures_path)

    config.read

    expect(config.fetch(:settings, :base)).to eq('USD')
  end

  it "reads from a specified file and merges with defaults" do
    file = fixtures_path('investments.yml')
    config = TTY::Config.new
    config.set(:settings, :base, value: 'EUR')
    config.set(:settings, :top, value: 50)

    config.read(file)

    expect(config.fetch(:settings, :base)).to eq('USD')
    expect(config.fetch(:settings, :exchange)).to eq('CCCAGG')
    expect(config.fetch(:settings, :top)).to eq(50)
  end

  it "reads a json format" do
    file = fixtures_path('investments.json')
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq('investments')
    expect(config.extname).to eq('.json')
    expect(config.fetch(:settings, :base)).to eq('USD')
    expect(config.fetch(:coins)).to eq(["BTC", "ETH", "TRX", "DASH"])
  end

  it "reads a toml format" do
    file = fixtures_path('investments.toml')
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq('investments')
    expect(config.extname).to eq('.toml')
    expect(config.fetch(:settings, :base)).to eq('USD')
    expect(config.fetch(:coins)).to eq(["BTC", "ETH", "TRX", "DASH"])
  end

  it "reads an ini format" do
    file = fixtures_path('investments.ini')
    config = TTY::Config.new

    config.read(file)

    expect(config.filename).to eq('investments')
    expect(config.extname).to eq('.ini')
    expect(config.fetch(:settings, :base)).to eq('USD')
    expect(config.fetch(:coins).split(',')).to eq(["BTC", "ETH", "TRX", "DASH"])
  end

  it "reads custom format" do
    file = fixtures_path('.env')
    config = TTY::Config.new

    config.read(file, format: :ini)

    expect(config.filename).to eq('.env')
    expect(config.extname).to eq('')
    expect(config.fetch(:settings, :base)).to eq('USD')
    expect(config.fetch(:coins).split(',')).to eq(["BTC", "ETH", "TRX", "DASH"])
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
    file = fixtures_path('unknown.yml')

    expect {
      config.read(file)
    }.to raise_error(TTY::Config::ReadError,
                    "Configuration file `#{file}` does not exist!")
  end
end
