require 'rails_helper'

RSpec.describe Account do
  it 'is valid with open id provider' do
    account = described_class.new
    account.open_id_providers.new(sub: '111111111111111111111', provider: 'google')

    expect(account).to be_valid
  end

  it 'is invalid without open id provider sub' do
    account = described_class.new
    account.open_id_providers.new(provider: 'google')

    expect(account).not_to be_valid
  end

  it 'is invalid without open id provider provider' do
    account = described_class.new
    account.open_id_providers.new(sub: '111111111111111111111')

    expect(account).not_to be_valid
  end

  it 'is invalid without open id provider' do
    account = described_class.new

    expect(account).not_to be_valid
  end
end
