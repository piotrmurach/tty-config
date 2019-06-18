RSpec.describe TTY::Config, '#merge' do
  it "merges nested hash" do
    config = TTY::Config.new
    config.set(:a, :b, value: 1)
    config.set(:a, :c, value: 2)

    config.merge({'a' => {'c' => 3, 'd' => 4}})

    expect(config.fetch(:a, :b)).to eq(1)
    expect(config.fetch(:a, :c)).to eq(3)
    expect(config.fetch(:a, :d)).to eq(4)
  end

  it "only merges hash like objects" do
    config = TTY::Config.new
    config.set(:a, :b, value: 1)

    config.merge(Object.new)

    expect(config.to_hash).to match({"a" => {"b" => 1}})
  end
end
