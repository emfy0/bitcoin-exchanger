class UpdateRatesJob < ApplicationJob
  queue_as :default

  def perform
    all_currecies = Currency.all

    all_currecies.each do |cur|
      unless cur.rate_to_btc == cur.to_BTC_by_API
        cur.update_rate!

        ActionCable.server.broadcast 'exchange_rate', cur.name => float_to_str(cur.rate_to_btc)
      end
    end
  end

  private

  def float_to_str(str)
    sprintf("%.8f", str)
  end
end
