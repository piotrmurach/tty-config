# frozen_string_literal: true

require "rspec-benchmark"
require "yaml/store"

RSpec.describe TTY::Config do
  include RSpec::Benchmark::Matchers

  it "reads and writes keys at most 1.5x slower than built-in yaml store" do
    config_file = tmp_path("config.yml")
    config = TTY::Config.new

    store_file = tmp_path("store.yml")
    store = YAML::Store.new(store_file)

    expect {
      config.set(:foo, value: "bar")
      config.write(config_file, force: true)
    }.to perform_slower_than {
      store.transaction { store[:foo] = "bar" }
    }.at_most(1.5).times
  end
end
