require 'rails_helper'

RSpec.describe Account do
  it 'is valid with sub and provider' do
    account = described_class.new(sub: '111111111111111111111', provider: 'google')

    expect(account).to be_valid
  end

  it 'is invalid without sub' do
    account = described_class.new(provider: 'google')

    expect(account).not_to be_valid
  end

  it 'is invalid without provider' do
    account = described_class.new(sub: '111111111111111111111')

    expect(account).not_to be_valid
  end
end
