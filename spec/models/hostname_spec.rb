require 'rails_helper'

RSpec.describe Hostname, type: :model do
  describe 'validations' do
    let(:hostname) { build(:hostname) }

    subject(:hostname_validations) { described_class.new(hostname.attributes).valid? }

    context 'presence' do
      context '.hostname' do
        context 'when hostname attribute is nil' do
          let(:hostname) { build(:hostname, hostname: nil) }

          it 'retuns DnsRecord invalid' do
            is_expected.to be false
          end
        end

        context 'when hostname attribute is not nil' do
          let(:hostname) { build(:hostname) }

          it 'retuns DnsRecord valid' do
            is_expected.to be true
          end
        end
      end
    end

    context 'uniqueness' do
      let!(:hostname_persisted) { create(:hostname) }

      context '.hostname' do
        context 'when hostname attribute is duplicated' do
          let(:hostname) { build(:hostname, hostname: hostname_persisted.hostname) }

          it 'retuns DnsRecord invalid' do
            is_expected.to be false
          end
        end

        context 'when hostname attribute is not duplicated' do
          let(:hostname) { build(:hostname) }

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

    context 'when there is no hostnames' do
      it 'returns empty' do
        is_expected.to be_empty
      end
    end

    context 'when there is hostnames' do
      let!(:hostname_1) { create(:hostname) }
      let!(:hostname_2) { create(:hostname) }
      let!(:hostname_3) { create(:hostname) }
      
      context 'and receive only included parameter' do
        let(:included) { [hostname_1.hostname, hostname_2.hostname].join(',') }

        it 'returns only hostnames with included parameters' do
          is_expected.to include(hostname_1, hostname_2)
          is_expected.to_not include(hostname_3)
        end
      end
  
      context 'and receive only excluded parameter' do
        let(:excluded) { [hostname_1.hostname, hostname_3.hostname].join(',') }

        it 'returns only hostnames without excluded parameters' do
          is_expected.to include(hostname_2)
          is_expected.to_not include(hostname_1, hostname_3)
        end
      end
  
      context 'and receive included and excluded parameter' do
        let(:included) { hostname_1.hostname }
        let(:excluded) { hostname_2.hostname }

        it 'returns hostnames with included and without excluded parameters' do
          is_expected.to include(hostname_1)
          is_expected.to_not include(hostname_2, hostname_3)
        end
      end
    end

    context 'when raise error' do
      before do
        allow(Hostname).to receive(:limit).and_raise(StandardError)
      end

      it 'returns empty' do
        expect(Hostname).to receive(:limit)

        is_expected.to be_empty
      end
    end
  end
end
