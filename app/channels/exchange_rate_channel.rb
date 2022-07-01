class ExchangeRateChannel < ApplicationCable::Channel
  def subscribed
    stream_from "exchange_rate"
    logger.info "Subscribed to exchange_rate"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
