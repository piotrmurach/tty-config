# frozen_string_literal: true

RSpec.describe TTY::Config, "#exist?", type: :sandbox do
  it "checks if configuration file exists" do |example|
    config = TTY::Config.new
    config.append_path example.metadata[:tmpdir]

    expect(config.exist?).to eq(false)

    config.write("investments.yml")

    expect(config.exist?).to eq(true)
  end

  it "checks if a file without extension is present" do |example|
    config = TTY::Config.new
    config.append_path example.metadata[:tmpdir]

    expect(config.exist?).to eq(false)

    config.write("investments", format: :yml)

    expect(config.exist?).to eq(true)
    expect(config.persisted?).to eq(true)
  end
end
