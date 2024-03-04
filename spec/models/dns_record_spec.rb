require 'rails_helper'

RSpec.describe DnsRecord, type: :model do
  describe 'validations' do
    let(:dns_record) { build(:dns_record) }

    subject(:dns_record_validations) { described_class.new(dns_record.attributes).valid? }

    context 'presence' do
      context '.ip' do
        context 'when ip attribute is nil' do
          let(:dns_record) { build(:dns_record, ip: nil) }

          it 'retuns DnsRecord invalid' do
            is_expected.to be false
          end
        end

        context 'when ip attribute is not nil' do
          let(:dns_record) { build(:dns_record) }

          it 'retuns DnsRecord valid' do
            is_expected.to be true
          end
        end
      end
    end

    context 'uniqueness' do
      let!(:dns_record_persisted) { create(:dns_record) }

      context '.ip' do
        context 'when ip attribute is duplicated' do
          let(:dns_record) { build(:dns_record, ip: dns_record_persisted.ip) }

          it 'retuns DnsRecord invalid' do
            is_expected.to be false
          end
        end

        context 'when ip attribute is not duplicated' do
          let(:dns_record) { build(:dns_record) }

          it 'retuns DnsRecord valid' do
            is_expected.to be true
          end
        end
      end
    end
  end
end
