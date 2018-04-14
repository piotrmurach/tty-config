RSpec.describe TTY::Config, '#delete' do
  it "deletes the value" do
    config = TTY::Config.new
    config.set(:foo, value: 2)
    expect(config.delete(:foo)).to eq(2)
    expect(config.fetch(:foo)).to eq(nil)
  end

  it "deletes the value under deeply nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz) { 2 }
    expect(config.delete(:foo, :bar, :baz).call).to eq(2)
    expect(config.fetch(:foo, :bar, :baz)).to eq(nil)
  end

  it "deletes innermost key with array value" do
    config = TTY::Config.new
    config.set(:foo, :bar, value: [1,2,3])
    expect(config.delete(:foo, :bar)).to eq([1,2,3])
    expect(config.fetch(:foo, :bar)).to eq(nil)
  end
end
