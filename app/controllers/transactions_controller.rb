class TransactionsController < ApplicationController
  def new
    @transaction = Transaction.new
    @market_fee = Transaction::MARKET_FEE
    @miner_fee = Transaction::MINER_FEE

    @ust_exchange_rate = Currency.find_by(name: "UST").rate_to_btc
  end

  def create
    binding.irb
  end
end
