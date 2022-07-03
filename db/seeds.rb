CURRENCIES =
  %w[BTC UST].freeze

CURRENCIES.each do |cur|
  Currency.create(name: cur, rate_to_btc: Currency.currency_exchange_rate_in_btc_api(cur))
end
