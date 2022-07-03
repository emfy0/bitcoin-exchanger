require 'rails_helper'
require 'vcr_setup'

RSpec.describe Currency, type: :model do
  context described_class::BitfinexApi do
    describe '#exchange_rate', :vcr do
      let(:rate) { described_class.exchange_rate('BTC', 'USD') }

      it 'should return the exchange rate from <cur>, <to_cur>' do
        expect(rate).to be_a Float
      end

      it 'should return smth like correct rate' do
        expect(rate).not_to eq(0)
      end

      it 'should raise an exception if <cur> is unknown' do
        expect { described_class.exchange_rate('BTC', 'QWE') }
          .to raise_error(described_class::UnknownCurrency)
      end
    end
  end

  context 'self methods' do
    describe '#currency_exchange_rate_in_btc_api', :vcr do
      let(:rate) { described_class.currency_exchange_rate_in_btc_api('USD') }

      it 'should return exchange rate form <currency> to BTC by API' do
        expect(rate).to be_a Float
      end

      it 'should return smth like correct rate' do
        expect(rate).not_to eq(0)
      end

      it 'should raise an exception if <currency> is unknown' do
        expect { described_class.currency_exchange_rate_in_btc_api('QWE') }
          .to raise_error(described_class::BitfinexApi::UnknownCurrency)
      end
    end

    describe '#rate_to_btc_by_name' do
      before { described_class.create(name: 'USD', rate_to_btc: 0.1) }
      let(:rate) { described_class.rate_to_btc_by_name('USD') }

      it 'should return exchange rate form <currency> to BTC by DB' do
        expect(rate).to be_a Float
      end
    end
  end

  describe '#to_BTC_by_API', :vcr do
    let(:currency_rate) { described_class.create(name: 'USD', rate_to_btc: 0.1).to_BTC_by_API }

    it 'should return exchanging currency rate to BTC by API' do
      expect(currency_rate).to be_a Float
    end

    it 'should return smth like correct rate' do
      expect(currency_rate).not_to eq(0)
    end
  end

  describe '#update_rate!', :vcr do
    let(:currency) { described_class.create(name: 'USD', rate_to_btc: 0.1) }

    it 'should update rate' do
      expect { currency.update_rate! }.to(change { currency.rate_to_btc })
    end

    context 'and should update rate to smth looks like correct' do
      before { currency.update_rate! }

      it 'should be Float' do
        expect(currency.rate_to_btc).to be_a Float
      end

      it 'shouldnt be zero' do
        expect(currency.rate_to_btc).not_to eq(0)
      end
    end
  end
end
