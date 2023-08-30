require 'rails_helper'

# 仮りで全てのエンドポイントを定義し、正常に応答することだけ確認
RSpec.describe 'Tasks' do
  describe 'POST /tasks' do
    before do
      post '/tasks'
    end

    it 'returns 200 as dummy.' do
      expect(response).to have_http_status(200)
    end

    it 'returns empty json' do
      expect(response.body).to eq('{}')
    end
  end

  describe 'PATCH /tasks/:id/stop' do
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

  describe 'PATCH /tasks/:id/complete' do
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

  describe 'GET /tasks/recording' do
    before do
      get '/tasks/recording'
    end

    context 'when recording tasks not exists' do
      it 'returns http ok' do
        expect(response).to have_http_status(200)
      end

      it 'returns empty list' do
        expect(JSON.parse(response.body)).to eq({ 'tasks' => [] })
      end
    end
  end

  describe 'GET /tasks/pending' do
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
