require 'bitcoin'

Bitcoin.network = :testnet3

module TransactionManager
  class Builder
    include BlockstreamApi
    include ActiveModel::Model
    include Bitcoin::Builder

    attr_accessor :cur_code_send, :cur_code_get, :to_send_value, :to_get_value,
                  :recipient_address, :email, :terms

    validates :cur_code_send, :cur_code_get, :to_send_value, :to_get_value, :recipient_address, :email, :terms,
              presence: true

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates_acceptance_of :terms
    validate :correct_recipient_address
    validates :to_send_value,
              numericality: { less_than_or_equal_to: TransactionManager::Constants::MAX_TRANSACTION_SUM_IN_USDT,
                              greater_than: 0 }
    validates :to_get_value, numericality: { greater_than: 0 }
    validate :to_get_value_less_than_or_equal_to_30_ust

    def build_transaction
      shatoshi_to_send = convert_btc_str_to_satoshi(to_get_value)
      utxos = BlockstreamApi.addr_utxo_list(addr)

      balance_after_transaction =
        BlockstreamApi.addr_balace(addr) - shatoshi_to_send - TransactionManager::Constants::MINER_FEE * 100_000_000

      raise NotEnoughBalance if balance_after_transaction.negative?

      utxos.uniq!(&:hash)

      database_transaction = create_db_record
      builded_transaction = build_tx do |transaction|
        utxos.each do |utxo|
          make_transaction_input transaction: transaction, prev_transaction: utxo,
                                 prev_transaction_indexs: addr_indexs_in_transaction_out(transaction: utxo, address: addr),
                                 sign_key: TransactionManager::Constants::KEY
        end

        transaction.output do |o|
          o.value shatoshi_to_send
          o.script { |s| s.recipient recipient_address }
        end

        transaction.output do |o|
          o.value balance_after_transaction
          o.script { |s| s.recipient addr }
        end
      end

      { transaction: builded_transaction, transaction_in_db: database_transaction }
    end

    private

    class NotEnoughBalance < StandardError; end

    def addr
      TransactionManager::Constants::KEY.addr
    end

    def create_db_record
      send_value_rate = Currency.rate_to_btc_by_name(cur_code_send)
      get_value_rate = Currency.rate_to_btc_by_name(cur_code_get)

      Transaction.create(email: email,
                         income_cur_code: cur_code_send,
                         outcome_cur_code: cur_code_get,
                         wallet_address: addr,
                         recipient_address: recipient_address,
                         income_in_btc: send_value_rate * to_send_value.to_f,
                         outcome_in_btc: get_value_rate * to_get_value.to_f,
                         income_rate_to_btc: send_value_rate,
                         outcome_rate_to_btc: get_value_rate,
                         network_fee: TransactionManager::Constants::MINER_FEE)
    end

    def make_transaction_input(transaction:, prev_transaction:, prev_transaction_indexs:, sign_key:)
      prev_transaction_indexs.each do |prev_transaction_index|
        transaction.input do |i|
          i.prev_out prev_transaction
          i.prev_out_index prev_transaction_index
          i.signature_key sign_key
        end
      end
    end

    def addr_indexs_in_transaction_out(transaction:, address:)
      transaction_out = transaction.to_hash(with_address: true)['out']
      transaction_out.each_index.select { |i| transaction_out[i]['address'] == address }
    end

    def convert_btc_str_to_satoshi(btc)
      (btc.to_f * 100_000_000).to_i
    end

    def correct_recipient_address
      unless Bitcoin.valid_address?(recipient_address)
        errors.add(:recipient_address,
                   I18n.t('errors.recipient_address'))
      end
    end

    def to_get_value_less_than_or_equal_to_30_ust
      cur_to_btc_rate = Currency.rate_to_btc_by_name(cur_code_send)
      to_get_value_in_ust = to_get_value.to_f / cur_to_btc_rate

      unless to_get_value_in_ust <= TransactionManager::Constants::MAX_TRANSACTION_SUM_IN_USDT
        errors.add(:to_get_value,
                   I18n.t('errors.to_get_value', value: TransactionManager::Constants::MAX_TRANSACTION_SUM_IN_USDT))
      end
    end
  end
end
