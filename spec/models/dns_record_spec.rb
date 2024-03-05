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

  describe ".search" do
    let(:limit) { 30 }
    let(:offset) { 0 }
    let(:included) { nil }
    let(:excluded) { nil }

    subject(:search) { described_class.search(limit, offset, included, excluded) }

    context 'when there is no dns_record' do
      let(:expected_response) { { records: [], related_hostnames: [] } }

      it 'returns records empty' do
        is_expected.to eq expected_response
      end
    end

    context 'when there is dns_record' do
      let!(:dns_1) { create(:dns_record) }
      let!(:dns_2) { create(:dns_record) }
      let!(:dns_3) { create(:dns_record) }
      let!(:dns_4) { create(:dns_record) }
      let!(:hostname_1) { create(:hostname) }
      let!(:hostname_2) { create(:hostname) }
      let!(:hostname_3) { create(:hostname) }

      before do
        dns_1.hostnames << hostname_1
        dns_1.hostnames << hostname_2
        dns_1.hostnames << hostname_3

        dns_2.hostnames << hostname_1
        dns_2.hostnames << hostname_2

        dns_3.hostnames << hostname_1
        dns_3.hostnames << hostname_3
        
        dns_4.hostnames << hostname_2
      end
      
      context 'and receive only included parameter' do
        let(:included) { [hostname_1.hostname, hostname_2.hostname].join(',') }
        let(:number_hostname_not_included_appear) { 1 }
        let(:expected_response) do
          {
            records: [{ id: dns_1.id, ip_address: dns_1.ip }, { id: dns_2.id, ip_address: dns_2.ip }],
            related_hostnames: [{ hostname: hostname_3.hostname, count: number_hostname_not_included_appear }]
          }
        end

        it 'returns only hostnames with included parameters' do
          is_expected.to eq expected_response
        end
      end
  
      context 'and receive only excluded parameter' do
        let(:excluded) { [hostname_1.hostname, hostname_3.hostname].join(',') }
        let(:number_hostname_not_included_appear) { 1 }
        let(:expected_response) do
          {
            records: [{ id: dns_4.id, ip_address: dns_4.ip }],
            related_hostnames: [{ hostname: hostname_2.hostname, count: number_hostname_not_included_appear }]
          }
        end

        it 'returns only hostnames without excluded parameters' do
          is_expected.to eq expected_response
        end
      end
  
      context 'and receive included and excluded parameter' do
        let(:included) { hostname_1.hostname }
        let(:excluded) { hostname_2.hostname }
        let(:number_hostname_not_included_appear) { 1 }
        let(:expected_response) do
          {
            records: [{ id: dns_3.id, ip_address: dns_3.ip }],
            related_hostnames: [{ hostname: hostname_3.hostname, count: number_hostname_not_included_appear }]
          }
        end

        it 'returns hostnames with included and without excluded parameters' do
          is_expected.to eq expected_response
        end
      end
    end

    context 'when raise error' do
      before do
        allow(described_class).to receive(:joins).and_raise(StandardError)
      end

      it 'returns empty' do
        expect(described_class).to receive(:joins)

        is_expected.to eq({ records: [], related_hostnames: [] })
      end
    end
  end
end
