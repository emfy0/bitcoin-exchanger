module TransactionHelper
  def original_income_view(tx)
    "#{tx.income_in_btc / tx.income_rate_to_btc} #{tx.income_cur_code}"
  end

  def original_outcome_view(tx)
    "#{float_to_str(tx.outcome_in_btc / tx.outcome_rate_to_btc)} #{tx.outcome_cur_code}"
  end

  def network_fee(tx)
    "#{float_to_str tx.network_fee} BTC"
  end

  def exchange_fee(tx)
    "#{float_to_str(tx.income_in_btc - tx.outcome_in_btc - tx.network_fee)} BTC"
  end

  def exchange_rate(tx)
    "1 #{tx.income_cur_code} ~ #{float_to_str(tx.income_rate_to_btc / tx.outcome_rate_to_btc)} #{tx.outcome_cur_code}"
  end
end
