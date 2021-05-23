# frozen_string_literal: true

require "rspec-benchmark"
require "yaml/store"

RSpec.describe TTY::Config, type: :sandbox do
  include RSpec::Benchmark::Matchers

  it "reads and writes keys at most 2x slower than built-in yaml store" do
    config = TTY::Config.new
    store = YAML::Store.new("store.yml")

    expect {
      config.set(:foo, value: "bar")
      config.write(force: true)
    }.to perform_slower_than {
      store.transaction { store[:foo] = "bar" }
    }.at_most(2).times
  end
end
