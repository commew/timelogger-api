require 'rails_helper'

RSpec.describe 'Accounts' do
  describe 'POST /post' do
    open_id_providers = {
      sub: '111111111111111111111',
      provider: 'google'
    }

    it 'returns http created' do
      post '/accounts', params: open_id_providers

      expect(response).to have_http_status(:created)
    end

    it 'returns requested Request-Id in header' do
      post '/accounts', params: open_id_providers, headers: {
        'Request-Id': '1234-5678'
      }

      expect(response.headers['Request-Id']).to eq('1234-5678')
    end

    it 'returns id' do
      post '/accounts', params: open_id_providers

      expect(JSON.parse(response.body)['id']).to be_an(Integer)
    end

    it 'returns sub and provider in openIdProviders' do
      post '/accounts', params: open_id_providers

      expect(JSON.parse(response.body)['openIdProviders']).to eq(
        {
          'sub' => '111111111111111111111',
          'provider' => 'google'
        }
      )
    end
  end
end
