require 'rails_helper'

RSpec.describe 'Accounts' do
  describe 'POST /accounts' do
    valid_authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      'valid_user',
      'valid_password'
    )

    invalid_authorization = ActionController::HttpAuthentication::Basic.encode_credentials(
      'valid_user',
      'invalid_password'
    )

    valid_headers = {
      Authorization: valid_authorization
    }

    invalid_headers = {
      Authorization: invalid_authorization
    }

    open_id_providers = {
      sub: '111111111111111111111',
      provider: 'google'
    }

    it 'returns http created' do
      post '/accounts', params: open_id_providers, headers: valid_headers

      expect(response).to have_http_status(201)
    end

    it 'returns http unauthorized' do
      post '/accounts', params: open_id_providers, headers: invalid_headers

      expect(response).to have_http_status(401)
    end

    it 'returns requested Request-Id in header' do
      post '/accounts', params: open_id_providers, headers: valid_headers.merge(
        {
          'Request-Id': '1234-5678'
        }
      )

      expect(response.headers['Request-Id']).to eq('1234-5678')
    end

    it 'returns id' do
      post '/accounts', params: open_id_providers, headers: valid_headers

      expect(JSON.parse(response.body)['id']).to be_an(Integer)
    end

    it 'returns sub and provider in openIdProviders' do
      post '/accounts', params: open_id_providers, headers: valid_headers

      expect(JSON.parse(response.body)['openIdProviders']).to eq(
        [
          {
            'sub' => '111111111111111111111',
            'provider' => 'google'
          }
        ]
      )
    end

    it 'returns bad request if account already exists' do
      post '/accounts', params: open_id_providers, headers: valid_headers
      post '/accounts', params: open_id_providers, headers: valid_headers

      expect(response).to have_http_status(400)
    end

    it 'returns appropriate message if account already exists' do
      post '/accounts', params: open_id_providers, headers: valid_headers
      post '/accounts', params: open_id_providers, headers: valid_headers

      expect(JSON.parse(response.body)).to eq(
        {
          'type' => 'BAD_REQUEST',
          'title' => 'Bad Request.',
          'detail' => 'Account already exists.'
        }
      )
    end

    it 'returns 422 if sub is not presented' do
      post '/accounts', params: { provider: 'google' }, headers: valid_headers

      expect(response).to have_http_status(422)
    end

    it 'returns 422 if provider is not presented' do
      post '/accounts', params: { sub: '111111111111111111111' }, headers: valid_headers

      expect(JSON.parse(response.body)).to eq(
        {
          'type' => 'UNPROCESSABLE_ENTITY',
          'title' => 'Unprocessable Entity.',
          'invalidParams' => [
            {
              'name' => 'provider',
              'reason' => "can't be blank"
            }
          ]
        }
      )
    end
  end
end
