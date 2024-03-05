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
end
