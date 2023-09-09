require 'rails_helper'

# 仮りで全てのエンドポイントを定義し、正常に応答することだけ確認
RSpec.describe 'Tasks' do
  describe 'POST /tasks' do
    before do
      post '/tasks', headers:, params:
    end

    let(:task_category) { create(:task_category) }

    let(:open_id_provider) do
      {
        sub: '111111111111111111111',
        provider: 'google'
      }
    end
    let(:account) do
      # factory ではなく .create_with_open_id_provider により
      # TaskGroup を初期でセットする
      Account.create_with_open_id_provider(**open_id_provider)
    end
    let(:headers) do
      token = JWT.encode(open_id_provider, Rails.application.config_for(:auth)[:jwt_hmac_secret])
      {
        Authorization: "Bearer #{token}"
      }
    end

    context 'when success' do
      let(:params) do
        {
          taskGroupId: task_category.task_group.id,
          taskCategoryId: task_category.id,
          status: 'recording',
          startAt: '2019-08-24T14:15:22Z'
        }
      end

      it 'returns 201.' do
        expect(response).to have_http_status(201)
      end

      it 'returns empty json' do
        p response.body
        expect(response.body).to eq('{}')
      end
    end
  end

  describe 'PATCH /tasks/:id/stop', skip: 'not implemented yet' do
    before do
      patch '/tasks/1/stop'
    end

    it 'returns 200 as dummy.' do
      expect(response).to have_http_status(200)
    end

    it 'returns empty json' do
      expect(response.body).to eq('{}')
    end
  end

  describe 'PATCH /tasks/:id/complete', skip: 'not implemented yet' do
    before do
      patch '/tasks/2/complete'
    end

    it 'returns 200 as dummy.' do
      expect(response).to have_http_status(200)
    end

    it 'returns empty json' do
      expect(response.body).to eq('{}')
    end
  end

  describe 'GET /tasks/recording', skip: 'not implemented yet' do
    before do
      get '/tasks/recording'
    end

    it 'returns 200 as dummy.' do
      expect(response).to have_http_status(200)
    end

    it 'returns empty json' do
      expect(response.body).to eq('{}')
    end
  end

  describe 'GET /tasks/pending', skip: 'not implemented yet' do
    before do
      get '/tasks/pending'
    end

    it 'returns 200 as dummy.' do
      expect(response).to have_http_status(200)
    end

    it 'returns empty json' do
      expect(response.body).to eq('{}')
    end
  end
end
