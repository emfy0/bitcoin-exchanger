module TransactionManager
  class Broadcaster
    def self.call(hash)
      new(hash).broadcast_transaction
    end

    def initialize(hash)
      @transaction = hash[:transaction]
      @transaction_in_db = hash[:transaction_in_db]
    end

    def broadcast_transaction
      res = BlockstreamApi.broadcast_transaction(@transaction)

      @transaction_in_db.update(status: true, txid: res.body) if res.is_a?(Net::HTTPSuccess)

      @transaction_in_db
    end
  end
end
