require 'bitcoin'

Bitcoin.network = :testnet3

module TransactionManager
  module Constants
    MINER_FEE = 0.000006
    MARKET_FEE = 0.03

    MAX_TRANSACTION_SUM_IN_USDT = 30

    KEY = Bitcoin::Key.from_base58(Rails.application.credentials.base_58_key)
  end
end
