require 'json'
require 'net/http'
require 'open-uri'
require 'bitcoin'

Bitcoin.network = :testnet3

class TransactionManager
  include ActiveModel::Model
  include Bitcoin::Builder

  attr_accessor :cur_code_send, :cur_code_get, :to_send_value, :to_get_value,
                :recipient_address, :email, :terms, :db_tx

  MINER_FEE = 0.000006
  MARKET_FEE = 0.03

  MAX_TRANSACTION_SUM_IN_USDT = 30

  KEY = Bitcoin::Key.from_base58(Rails.application.credentials.base_58_key)

  validates :cur_code_send, :cur_code_get, :to_send_value, :to_get_value, :recipient_address, :email, :terms,
            presence: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_acceptance_of :terms
  validate :correct_recipient_address
  validates :to_send_value, numericality: { less_than_or_equal_to: MAX_TRANSACTION_SUM_IN_USDT, greater_than: 0 }
  validates :to_get_value, numericality: { greater_than: 0 }
  validate :to_get_value_less_than_or_equal_to_30_ust

  module BlockstreamApi
    extend self
    BLOCKSTREAM_API_URL = 'https://blockstream.info/testnet/api/'.freeze

    def addr_balace(address)
      res = open("#{BLOCKSTREAM_API_URL}address/#{address}")
      addr_info = JSON.parse(res.string)
      chain_stats = addr_info['chain_stats']
      mempool_stats = addr_info['mempool_stats']

      chain_stats['funded_txo_sum'] - chain_stats['spent_txo_sum'] +
        mempool_stats['funded_txo_sum'] - mempool_stats['spent_txo_sum']
    end

    def utxo_ids_by_addr(address)
      res = open("#{BLOCKSTREAM_API_URL}address/#{address}/utxo")
      utxo = JSON.parse(res.string)
      utxo.map { |t| t['txid'] }
    end

    def tx_by_id(txid)
      res = open("#{BLOCKSTREAM_API_URL}tx/#{txid}/raw")
      Bitcoin::Protocol::Tx.new(res)
    end

    def addr_utxo_list(address)
      utxo_ids_by_addr(address).map { |txid| tx_by_id txid }
    end

    def broadcast_transaction(tx)
      url = URI("#{BLOCKSTREAM_API_URL}tx")
      Net::HTTP.post url, tx.to_payload.bth
    end
  end

  class NotEnoughBalance < StandardError; end

  def addr
    KEY.addr
  end

  def build_transaction
    shatoshi_to_send = convert_btc_str_to_satoshi(to_get_value)
    utxos = BlockstreamApi.addr_utxo_list(addr)

    balance_after_tx = BlockstreamApi.addr_balace(addr) - shatoshi_to_send - MINER_FEE * 100_000_000
    raise NotEnoughBalance.new if balance_after_tx.negative?

    utxos.uniq!(&:hash)

    @db_tx = create_db_record
    @builded_tx = build_tx do |transaction|
      utxos.each do |utxo|
        make_tx_input tx: transaction, prev_tx: utxo,
                      prev_tx_indexs: addr_indexs_in_tx_out(tx: utxo, address: addr), sign_key: KEY
      end

      transaction.output do |o|
        o.value shatoshi_to_send
        o.script { |s| s.recipient recipient_address }
      end

      transaction.output do |o|
        o.value balance_after_tx
        o.script { |s| s.recipient addr }
      end
    end
  end

  def broadcast_transaction
    res = BlockstreamApi.broadcast_transaction(@builded_tx)

    @db_tx.update(status: true, txid: res.body) if res.is_a?(Net::HTTPSuccess)

    @db_tx
  end

  def build_and_broadcast_transaction
    build_transaction
    broadcast_transaction
  end

  private

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
                       network_fee: MINER_FEE)
  end

  def make_tx_input(tx:, prev_tx:, prev_tx_indexs:, sign_key:)
    prev_tx_indexs.each do |prev_tx_index|
      tx.input do |i|
        i.prev_out prev_tx
        i.prev_out_index prev_tx_index
        i.signature_key sign_key
      end
    end
  end

  def addr_indexs_in_tx_out(tx:, address:)
    out = tx.to_hash(with_address: true)['out']
    out.each_index.select { |i| out[i]['address'] == address }
  end

  def convert_btc_str_to_satoshi(btc)
    (btc.to_f * 100_000_000).to_i
  end

  def correct_recipient_address
    errors.add(:recipient_address, I18n.t('errors.recipient_address')) unless Bitcoin.valid_address?(recipient_address)
  end

  def to_get_value_less_than_or_equal_to_30_ust
    cur_to_btc_rate = Currency.rate_to_btc_by_name(cur_code_send)
    to_get_value_in_ust = to_get_value.to_f / cur_to_btc_rate

    unless to_get_value_in_ust <= MAX_TRANSACTION_SUM_IN_USDT
      errors.add(:to_get_value, I18n.t('errors.to_get_value', value: MAX_TRANSACTION_SUM_IN_USDT))
    end
  end
end
