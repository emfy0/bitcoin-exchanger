require 'rails_helper'
require 'vcr_setup'
require 'bitcoin'

RSpec.describe TransactionManager, type: :model do
  describe described_class::Builder do
    context 'validations' do
      before do
        Currency.create(name: 'UST', rate_to_btc: 0.00005250)
        Currency.create(name: 'BTC', rate_to_btc: 1)
      end

      let(:new_transaction) do
        described_class.new(cur_code_send: 'UST',
                            cur_code_get: 'BTC',
                            to_send_value: '1',
                            to_get_value: '0.00004492',
                            recipient_address: 'mkuKjJGEe3JabSbBk6kfNSLgiqFi6m97mi',
                            email: '123@123.123',
                            terms: true)
      end

      it 'should be valid with valid attributes' do
        expect(new_transaction).to be_valid
      end

      it 'shouldnt be valid with valid with incorrect recipient address' do
        new_transaction.recipient_address = '123@123.123'
        expect(new_transaction).to_not be_valid
      end

      it 'shouldnt be valid with to_get_value more than 30 USDT equivalent' do
        new_transaction.to_get_value = '0.00162360'
        expect(new_transaction).to_not be_valid
      end
    end
  end

  context described_class::BlockstreamApi, :vcr do
    describe '#addr_balace' do
      let(:addr_balace) { described_class.addr_balace('mkuKjJGEe3JabSbBk6kfNSLgiqFi6m97mi') }

      it 'should return smth like address balace' do
        expect(addr_balace).to be_a Integer
      end
    end

    describe '#utxo_ids_by_addr' do
      let(:utxo_ids) { described_class.utxo_ids_by_addr('mkuKjJGEe3JabSbBk6kfNSLgiqFi6m97mi') }

      it 'should return array of utxo_ids' do
        expect(utxo_ids).to be_a Array
      end

      it 'array elements should look like utxo_id' do
        utxo_ids.each do |utxo_id|
          expect(utxo_id).to be_a String
        end
      end
    end

    describe '#transaction_by_id' do
      let(:tx) do
        described_class.transaction_by_id('665db7e88690ad3e31f87c74b729b1d2569e1d93d24ab1c4537ffd8264b4bec2')
      end

      it 'should return Bitcoin::Protocol::Tx instance' do
        expect(tx).to be_a Bitcoin::Protocol::Tx
      end
    end

    describe '#addr_utxo_list' do
      let(:addr_utxos) do
        described_class.addr_utxo_list('mkuKjJGEe3JabSbBk6kfNSLgiqFi6m97mi')
      end

      it 'should return an array of addr utxos' do
        expect(addr_utxos).to be_a Array
      end

      it 'array should contain instances of Bitcoin::Protocol::Tx' do
        addr_utxos.each do |utxo|
          expect(utxo).to be_a Bitcoin::Protocol::Tx
        end
      end
    end
  end

  describe described_class::Builder do
    context '#build_transaction', :vcr do
      before do
        Currency.create(name: 'UST', rate_to_btc: 0.00005250)
        Currency.create(name: 'BTC', rate_to_btc: 1)
      end

      let(:new_transaction) do
        described_class.new(cur_code_send: 'UST',
                            cur_code_get: 'BTC',
                            to_send_value: '10',
                            to_get_value: '0.00050325',
                            recipient_address: 'mkuKjJGEe3JabSbBk6kfNSLgiqFi6m97mi',
                            email: '123@123.123',
                            terms: true)
      end

      context 'should create a new transaction', :vcr do
        it 'should raise NotEnoughBalance if it is not enough balance' do
          invalid_tx = TransactionManager::Builder.new(cur_code_send: 'UST',
                                                       cur_code_get: 'BTC',
                                                       to_send_value: '10',
                                                       to_get_value: '99999999999999',
                                                       recipient_address: 'mkuKjJGEe3JabSbBk6kfNSLgiqFi6m97mi',
                                                       email: '123@123.123',
                                                       terms: true)

          expect { invalid_tx.build_transaction }.to raise_error(described_class::NotEnoughBalance)
        end

        it 'should return instance of Hash' do
          expect(new_transaction.build_transaction).to be_a Hash
        end

        it 'should contain two keys' do
          expect(new_transaction.build_transaction.size).to eq(2)
        end

        it ':transaction value should contain two outputs' do
          expect(new_transaction.build_transaction[:transaction].out.count).to eq(2)
        end

        it 'should create new record in transactions db', :vcr do
          new_transaction.build_transaction
          expect(new_transaction.build_transaction[:transaction_in_db]).to be_a Transaction
        end

        it 'should output contains correct sum for user' do
          expect(new_transaction.build_transaction[:transaction].out[0].value).to eq(50_325)
        end

        it 'should output contains correct sum for market', :vcr do
          send_back_to_market =
            TransactionManager::BlockstreamApi.addr_balace(TransactionManager::Constants::KEY.addr) -
            (new_transaction.to_get_value.to_f * 100_000_000).to_i - TransactionManager::Constants::MINER_FEE * 100_000_000

          expect(new_transaction.build_transaction[:transaction].out[1].value).to eq(send_back_to_market)
        end
      end
    end
  end
end
