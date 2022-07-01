CURRENCIES =
  %w[BTC UST]

CURRENCIES.each do |cur|
  Currency.create(name: cur, rate_to_btc: Currency.currency_exchange_rate_in_btc(cur))
end
