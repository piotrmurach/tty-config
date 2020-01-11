# frozen_string_literal: true

RSpec.describe TTY::Config, '#remove' do
  it "removes a value from a key" do
    config = TTY::Config.new
    config.set(:values) { [:foo, :bar] }
    values = config.remove(:bar, from: :values)
    expect(values).to eq([:foo])
    expect(config.fetch(:values)).to eq([:foo])
  end

  it "removes multiple values from a nested key" do
    config = TTY::Config.new
    config.set(:foo, :bar, :baz) { [1,2,3,4] }
    config.remove(2,4, from: [:foo, :bar, :baz])
    expect(config.fetch(:foo, :bar, :baz)).to eq([1,3])
  end
end
