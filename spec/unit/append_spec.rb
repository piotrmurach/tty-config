# frozen_string_literal: true

RSpec.describe TTY::Config, '#append' do
  it "returns appended values" do
    config = TTY::Config.new
    values = config.append(:foo, :bar, to: :values)

    expect(values).to eq([:foo, :bar])
    expect(config.fetch(:values)).to eq([:foo, :bar])
  end

  it "appends values to already existing key" do
    config = TTY::Config.new
    config.set(:values) { :foo }
    values = config.append(:bar, :baz, to: :values)

    expect(config.fetch(:values)).to eq([:foo, :bar, :baz])
    expect(values).to eq([:foo, :bar, :baz])
  end

  it "appends values to nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar) { 1 }
    values = config.append(2,3, to: [:foo, :bar])
    expect(values).to eq([1,2,3])
    expect(config.fetch(:foo, :bar)).to eq([1,2,3])
  end
end
