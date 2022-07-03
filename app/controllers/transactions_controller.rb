class TransactionsController < ApplicationController
  def new
    initialize_new_variables
  end

  def create
    @transaction_new = TransactionManager.new(tx_params)

    if @transaction_new.valid?
      @transaction = @transaction_new.build_and_broadcast_transaction

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
    @market_fee = TransactionManager::MARKET_FEE
    @miner_fee = TransactionManager::MINER_FEE

    @ust_exchange_rate = Currency.find_by(name: 'UST').rate_to_btc
  end
end
