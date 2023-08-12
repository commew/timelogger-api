require 'rails_helper'

RSpec.describe 'Accounts' do
  describe 'GET /accounts' do
    before do
      get '/accounts', headers:
    end

    let(:valid_headers) do
      token = JWT.encode(
        { sub: '111111111111111111111', provider: 'google' },
        Rails.application.credentials.jwt_hmac_secret
      )

      {
        Authorization: "Bearer #{token}"
      }
    end

    let(:invalid_headers) do
      {
        Authorization: 'Bearer undefined'
      }
    end

    context 'when jwt token is valid' do
      let(:headers) { valid_headers }

      it 'returns http ok' do
        expect(response).to have_http_status(200)
      end

      # TODO: アカウント取得実装時に追加する
    end

    context 'when jwt token is invalid' do
      let(:headers) { invalid_headers }

      it 'returns http unauthorized' do
        expect(response).to have_http_status(401)
      end

      it 'returns appropriate type' do
        expect(JSON.parse(response.body)['type']).to eq('UNAUTHENTICATED')
      end

      it 'returns appropriate title' do
        expect(JSON.parse(response.body)['title']).to eq('Account is not authenticated.')
      end

      it 'returns appropriate detail' do
        expect(JSON.parse(response.body)['detail']).to eq('Not enough or too many segments')
      end
    end
  end

  describe 'POST /accounts' do
    let(:valid_headers) do
      {
        Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
          'valid_user',
          'valid_password'
        )
      }
    end

    let(:invalid_headers) do
      {
        Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
          'valid_user',
          'invalid_password'
        )
      }
    end

    let(:open_id_providers) do
      {
        sub: '111111111111111111111',
        provider: 'google'
      }
    end

    context 'when ok' do
      before do
        post '/accounts', params: open_id_providers, headers: valid_headers
      end

      it 'returns http created' do
        expect(response).to have_http_status(201)
      end

      it 'returns id' do
        expect(JSON.parse(response.body)['id']).to be_an(Integer)
      end

      it 'returns sub and provider in openIdProviders' do
        expect(JSON.parse(response.body)['openIdProviders']).to eq(
          [
            {
              'sub' => '111111111111111111111',
              'provider' => 'google'
            }
          ]
        )
      end
    end

    context 'when authorization failed' do
      before do
        post '/accounts', params: open_id_providers, headers: invalid_headers
      end

      it 'returns http unauthorized' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when request-id header included' do
      before do
        post '/accounts', params: open_id_providers, headers: valid_headers.merge(
          {
            'Request-Id': '1234-5678'
          }
        )
      end

      it 'returns requested Request-Id in header' do
        expect(response.headers['Request-Id']).to eq('1234-5678')
      end
    end

    context 'when account already exists' do
      before do
        post '/accounts', params: open_id_providers, headers: valid_headers
        post '/accounts', params: open_id_providers, headers: valid_headers
      end

      it 'returns bad request' do
        expect(response).to have_http_status(400)
      end

      it 'returns appropriate type' do
        expect(JSON.parse(response.body)['type']).to eq('BAD_REQUEST')
      end

      it 'returns appropriate title' do
        expect(JSON.parse(response.body)['title']).to eq('Bad Request.')
      end

      it 'returns appropriate detail' do
        expect(JSON.parse(response.body)['detail']).to eq('Account already exists.')
      end
    end

    context 'when sub and provider is not presented' do
      before do
        post '/accounts', params: {}, headers: valid_headers
      end

      it 'returns 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns appropriate error type' do
        expect(JSON.parse(response.body)['type']).to eq('UNPROCESSABLE_ENTITY')
      end

      it 'returns appropriate error title' do
        expect(JSON.parse(response.body)['title']).to eq('Unprocessable Entity.')
      end

      it 'returns error reasons' do
        expect(JSON.parse(response.body)['invalidParams']).to eq(
          [
            {
              'name' => 'sub',
              'reason' => "can't be blank"
            },
            {
              'name' => 'provider',
              'reason' => "can't be blank"
            }
          ]
        )
      end
    end
  end
end
