# frozen_string_literal: true

RSpec.describe TTY::Config, "#new" do
  it "sets settings through initialization" do
    config = TTY::Config.new(foo: "bar")
    expect(config.fetch(:foo)).to eq("bar")
  end
end
