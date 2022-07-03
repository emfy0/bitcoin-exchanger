require 'net/http'
require 'json'

class Currency < ApplicationRecord
  module BitfinexApi
    extend self
    BITFINEX_EXCHANGE_RATE_URL = 'https://api.bitfinex.com/v2/calc/fx'.freeze

    class UnknownCurrency < StandardError; end

    def exchange_rate(cur, to_cur)
      uri = URI(BITFINEX_EXCHANGE_RATE_URL)

      data = { ccy1: cur, ccy2: to_cur }.to_json

      res = Net::HTTP.post(uri, data, 'Content-Type' => 'application/json')

      if res.is_a?(Net::HTTPSuccess)
        res.body[1..-2].to_f
      else
        raise UnknownCurrency.new
      end
    end
  end

  class << self
    def currency_exchange_rate_in_btc_api(currency)
      BitfinexApi.exchange_rate(currency, 'BTC')
    end

    def rate_to_btc_by_name(cur_name)
      Currency.find_by(name: cur_name).rate_to_btc
    end
  end

  def to_BTC_by_API
    BitfinexApi.exchange_rate(name, 'BTC')
  end

  def update_rate!
    update(rate_to_btc: to_BTC_by_API)
  end
end
