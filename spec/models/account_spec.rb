require 'rails_helper'

RSpec.describe Account do
  let(:open_id_provider) do
    {
      sub: '111111111111111111111',
      provider: 'google'
    }
  end

  describe '.retrieve_by_open_id_provider' do
    context 'when account exists' do
      before do
        create(:account)
      end

      it 'returns account' do
        expect(described_class.retrieve_by_open_id_provider(sub: '111111111111111111111',
                                                            provider: 'google')).to be_a described_class
      end

      it 'does not return account' do
        expect(described_class.retrieve_by_open_id_provider(sub: '222222222222222222222', provider: 'google')).to be_nil
      end
    end
  end

  describe '.create_with_open_id_provider' do
    it 'is valid with open id provider' do
      account = described_class.create_with_open_id_provider(**open_id_provider)

      expect(account).to be_valid
    end

    it 'is invalid without open id provider sub' do
      account = described_class.create_with_open_id_provider(sub: '', provider: 'google')

      expect(account).not_to be_valid
    end

    it 'is invalid without open id provider provider' do
      account = described_class.create_with_open_id_provider(sub: '111111111111111111111', provider: '')

      expect(account).not_to be_valid
    end

    it 'is invalid without open id provider' do
      account = described_class.create_with_open_id_provider(sub: '', provider: '')

      expect(account).not_to be_valid
    end

    # このファイル全体が後でリファクタされる前提
    # TaskGroups が作成されることをテスト
    context 'when an accout created using .create_with_open_id_provider' do
      let(:account) do
        described_class.create_with_open_id_provider(**open_id_provider)
      end

      it 'are task_groups created' do
        expect(account.task_groups.first).to be_a TaskGroup
      end
    end
  end
end
