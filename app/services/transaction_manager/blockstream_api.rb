require 'json'
require 'net/http'
require 'open-uri'

module TransactionManager
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
      utxo.map { |transaction| transaction['txid'] }
    end

    def transaction_by_id(txid)
      res = open("#{BLOCKSTREAM_API_URL}tx/#{txid}/raw")
      Bitcoin::Protocol::Tx.new(res)
    end

    def addr_utxo_list(address)
      utxo_ids_by_addr(address).map { |transaction_id| transaction_by_id transaction_id }
    end

    def broadcast_transaction(transaction)
      url = URI("#{BLOCKSTREAM_API_URL}tx")
      Net::HTTP.post url, transaction.to_payload.bth
    end
  end
end
