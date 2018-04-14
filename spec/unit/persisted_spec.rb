RSpec.describe TTY::Config, '#persisted?', type: :cli do
  it "checks if configuration is persisted" do
    config = TTY::Config.new
    config.set(:settings, :base, value: 'USD')
    config.set(:settings, :exchange, value: 'CCCAGG')
    config.set(:coins, value: ['BTC', 'TRX', 'DASH'])

    config.append_path(tmp_path)

    expect(config.persisted?).to eq(false)

    config.write(tmp_path('investments.yml'))

    expect(config.persisted?).to eq(true)
  end
end
