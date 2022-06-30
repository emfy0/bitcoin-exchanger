class Transaction < ApplicationRecord
  validates_acceptance_of :terms, on: :create
end
