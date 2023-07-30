require 'rails_helper'

RSpec.describe Account do
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
