class Transaction < ApplicationRecord
  MINER_FEE = 0.000006
  MARKET_FEE = '3%'.freeze

  validates_acceptance_of :terms, on: :create
end
