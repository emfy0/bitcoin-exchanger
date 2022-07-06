class TransactionsController < ApplicationController
  def new
    initialize_new_variables
    @transaction_new = TransactionManager::Builder.new(to_send_value: 0, to_get_value: 0)
  end

  def create
    @transaction_new = TransactionManager::Builder.new(tx_params)

    if @transaction_new.valid?
      transaction = @transaction_new.build_transaction
      @transaction = TransactionManager::Broadcaster.call(transaction)

      render :show
    else
      initialize_new_variables

      render :new
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  private

  def tx_params
    params.require(:transaction).permit(:to_send_value, :to_get_value,
                                        :email, :recipient_address,
                                        :terms, :cur_code_send, :cur_code_get)
  end

  def initialize_new_variables
    @market_fee = TransactionManager::Constants::MARKET_FEE
    @miner_fee = TransactionManager::Constants::MINER_FEE

    @ust_exchange_rate = Currency.rate_to_btc_by_name('UST')
  end
end
