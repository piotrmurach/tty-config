RSpec.describe TTY::Config, '#exist?', type: :cli do
  it "checks if configuration file exists" do
    config = TTY::Config.new
    config.append_path(tmp_path)

    expect(config.exist?).to eq(false)

    config.write(tmp_path('investments.yml'))

    expect(config.exist?).to eq(true)
  end

  it "checks if a file without extension is present" do
    config = TTY::Config.new
    config.append_path tmp_path

    expect(config.exist?).to eq(false)

    config.write(tmp_path('investments'), format: :yml)

    expect(config.exist?).to eq(true)
  end
end
