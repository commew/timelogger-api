require 'rails_helper'

RSpec.describe Account do
  describe '.retrieve_by_open_id_provider' do
    context 'when account exists' do
      before do
        described_class.create_with_open_id_provider('111111111111111111111', 'google')
      end

      it 'returns account' do
        expect(described_class.retrieve_by_open_id_provider('111111111111111111111', 'google')).to be_a described_class
      end

      it 'does not return account' do
        expect(described_class.retrieve_by_open_id_provider('222222222222222222222', 'google')).to be_nil
      end
    end
  end

  describe '.create_with_open_id_provider' do
    it 'is valid with open id provider' do
      account = described_class.create_with_open_id_provider('111111111111111111111', 'google')

      expect(account).to be_valid
    end

    it 'is invalid without open id provider sub' do
      account = described_class.create_with_open_id_provider('', 'google')

      expect(account).not_to be_valid
    end

    it 'is invalid without open id provider provider' do
      account = described_class.create_with_open_id_provider('111111111111111111111', '')

      expect(account).not_to be_valid
    end

    it 'is invalid without open id provider' do
      account = described_class.create_with_open_id_provider('', '')

      expect(account).not_to be_valid
    end
  end
end
