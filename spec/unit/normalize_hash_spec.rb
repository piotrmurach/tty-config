# frozen_string_literal: true

RSpec.describe TTY::Config, "#normalize_hash" do
  it "normalizes keys via method to symbols" do
    hash = {
      "settings" => {
        "base" => "USD",
        "color" => true,
        "exchange" => "CCCAGG"
      },
      "coins" => ["BTC", "ETH", "TRX", "DASH"]
    }

    expect(TTY::Config.normalize_hash(hash)).to eq({
      settings: {
        base: "USD",
        color: true,
        exchange: "CCCAGG"
      },
      coins: ["BTC", "ETH", "TRX", "DASH"]
    })
  end
end
