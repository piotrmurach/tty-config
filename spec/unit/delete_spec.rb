RSpec.describe TTY::Config, '#delete' do
  it "deletes the value" do
    config = TTY::Config.new
    config.set(:foo, value: 2)
    config.delete(:foo)
    expect(config.fetch(:foo)).to eq(nil)
  end

  it "deletes the value under deeply nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz) { 2 }
    config.delete(:foo, :bar, :baz)
    expect(config.fetch(:foo, :bar, :baz)).to eq(nil)
  end
end
