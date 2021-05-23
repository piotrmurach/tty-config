# frozen_string_literal: true

RSpec.describe TTY::Config, "#remove" do
  it "fails without specifying the from keyword" do
    config = TTY::Config.new
    expect {
      config.remove(:foo)
    }.to raise_error(ArgumentError, "Need to set key to remove from")
  end

  it "doesn't remove value from the non-existent key" do
    config = TTY::Config.new
    values = config.remove(:bar, from: :foo)
    expect(values).to eq([])
  end

  it "removes a value from a key" do
    config = TTY::Config.new
    config.set(:values) { %i[foo bar] }
    values = config.remove(:bar, from: :values)
    expect(values).to eq([:foo])
    expect(config.fetch(:values)).to eq([:foo])
  end

  it "removes multiple values from a nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz) { [1, 2, 3, 4] }
    values = config.remove(2, 4, from: %i[foo bar baz])
    expect(values).to eq([1, 3])
    expect(config.fetch(:foo, :bar, :baz)).to eq([1, 3])
  end

  it "removes multiple values from a dot delimited nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz) { [1, 2, 3, 4] }
    values = config.remove(2, 4, from: "foo.bar.baz")
    expect(values).to eq([1, 3])
    expect(config.fetch(:foo, :bar, :baz)).to eq([1, 3])
  end
end
