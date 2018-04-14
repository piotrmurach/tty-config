RSpec.describe TTY::Config, '#write', type: :cli do
  it "writes configuration to a specified file" do
    config = TTY::Config.new
    config.set(:settings, :base, value: 'USD')
    config.set(:settings, :exchange, value: 'CCCAGG')
    config.set(:coins, value: ['BTC', 'TRX', 'DASH'])
    file = tmp_path('config.yml')

    config.write(file)

    expect(::File.read(file)).to eq <<-EOS
---
settings:
  base: USD
  exchange: CCCAGG
coins:
- BTC
- TRX
- DASH
    EOS
  end

  it "writes by default to the current directory" do
    config = TTY::Config.new
    config.set('settings', 'base', value: 'USD')
    config.set('settings', 'exchange', value: 'CCCAGG')
    config.set('coins', value: ['BTC', 'TRX', 'DASH'])

    config.write

    file = dir_path('config.yml')
    expect(::File.read(file)).to eq <<-EOS
---
settings:
  base: USD
  exchange: CCCAGG
coins:
- BTC
- TRX
- DASH
    EOS
    FileUtils.rm_rf(file)
  end

  it "doesn't override already existing file" do
    config = TTY::Config.new
    config.set('settings', 'base', value: 'USD')
    file = tmp_path('config.yml')

    config.write(file)

    expect {
      config.write(file)
    }.to raise_error(TTY::Config::WriteError,
      "File `#{file}` already exists. Use :force option to overwrite.")
  end

  it "allows to overwrite already existing file" do
    config = TTY::Config.new
    config.set('settings', 'base', value: 'USD')
    file = tmp_path('config.yml')

    config.write(file)

    config.write(file, force: true)
  end

  it "writes json format" do
    config = TTY::Config.new
    config.set(:settings, :base, value: 'USD')
    config.set(:settings, :exchange, value: 'CCCAGG')
    config.set(:coins, value: ['BTC', 'TRX', 'DASH'])
    file = tmp_path('config.json')

    config.write(file)

    expect(::File.read(file)).to eq <<-EOS.chomp
{
  "settings": {
    "base": "USD",
    "exchange": "CCCAGG"
  },
  "coins": [
    "BTC",
    "TRX",
    "DASH"
  ]
}
EOS
  end

  it "writes toml format" do
    config = TTY::Config.new
    config.set(:settings, :base, value: 'USD')
    config.set(:settings, :exchange, value: 'CCCAGG')
    config.set(:coins, value: ['BTC', 'TRX', 'DASH'])
    file = tmp_path('config.toml')

    config.write(file)

    expect(::File.read(file)).to eq <<-EOS.chomp
coins = ["BTC","TRX","DASH"]

[settings]
base = "USD"
exchange = "CCCAGG"

EOS
  end

  it "allows to change default file extension" do
    config = TTY::Config.new
    config.filename = 'investments'
    config.extname = '.toml'
    config.set(:settings, :base, value: 'USD')
    config.set(:settings, :exchange, value: 'CCCAGG')
    config.set(:coins, value: ['BTC', 'TRX', 'DASH'])

    config.write

    file = dir_path('investments.toml')
    expect(::File.read(file)).to eq <<-EOS.chomp
coins = ["BTC","TRX","DASH"]

[settings]
base = "USD"
exchange = "CCCAGG"

EOS
    FileUtils.rm_rf(file)
  end

  it "cannot write unknown file format" do
    config = TTY::Config.new
    config.set(:settings, :base, value: 'USD')
    file = tmp_path('config.txt')

    expect {
      config.write(file)
    }.to raise_error(TTY::Config::WriteError,
                    "Config file format `.txt` not supported.")
  end
end
