class AdminPanelController < ApplicationController
  http_basic_authenticate_with name: 'admin', password: 'admin', on: :show

  def show
    @total_tx = Transaction.count
    @total_success_tx = Transaction.where(status: true).count
    @tx_total_sum = Transaction.sum('income_in_btc - outcome_in_btc - network_fee')

    @transactions = Transaction.all
  end
end
