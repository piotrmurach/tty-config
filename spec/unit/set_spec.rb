RSpec.describe TTY::Config, '#set' do
  it "sets value" do
    config = TTY::Config.new
    config.set(:foo, value: :bar)
    expect(config.fetch(:foo)).to eq(:bar)
  end

  it "sets value as block" do
    config = TTY::Config.new
    config.set(:foo) { "bar" }
    expect(config.fetch(:foo)).to eq("bar")
  end

  it "sets value for deep ensted key" do
    config = TTY::Config.new
    value = config.set(:foo, :bar, :baz, value: 2)
    expect(value).to eq(2)
    expect(config.fetch(:foo, :bar, :baz)).to eq(2)
  end

  it "sets value as block for deep ensted key" do
    config = TTY::Config.new
    value = config.set(:foo, :bar, :baz) { 2 }
    expect(value.call).to eq(2)
    expect(config.fetch(:foo, :bar, :baz)).to eq(2)
  end

  it "sets value for deep nested string key delimited by ." do
    config = TTY::Config.new
    value = config.set("foo.bar.baz", value: 2)
    expect(value).to eq(2)
    expect(config.fetch('foo', 'bar', 'baz')).to eq(2)
  end

  it "sets value as block for deep nested string key delimited by ." do
    config = TTY::Config.new
    value = config.set("foo.bar.baz") { 2 }
    expect(value.call).to eq(2)
    expect(config.fetch('foo', 'bar', 'baz')).to eq(2)
  end

  it "overrides existing value" do
    config = TTY::Config.new({foo: {bar: 1}})
    expect(config.fetch(:foo, :bar)).to eq(1)
    config.set(:foo, :bar) { 2 }
    expect(config.fetch(:foo, :bar)).to eq(2)
  end

  it "raises an exception when value & block provided" do
    config = TTY::Config.new
    expect {
      config.set(:foo, value: :bar) { :baz }
    }.to raise_error(ArgumentError, "Can't set both value and block")
  end
end
