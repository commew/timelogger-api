require 'rails_helper'

# 仮りで全てのエンドポイントを定義し、正常に応答することだけ確認
RSpec.describe 'Tasks' do
  describe 'POST /tasks' do
    let(:task_category) { create(:task_category) }

    let(:account) { create(:account, task_groups: [task_category.task_group]) }

    let(:params) do
      {
        taskGroupId: task_category.task_group.id,
        taskCategoryId: task_category.id,
        status: Task::STATUS[:recording]
      }
    end

    context 'when task created' do
      before do
        post '/tasks', params:, headers: headers(account)
      end

      it 'returns http created' do
        expect(response).to have_http_status(201)
      end

      # TODO
    end

    # TODO: 異常系も
  end

  describe 'PATCH /tasks/:id/stop', skip: '未実装' do
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

  describe 'PATCH /tasks/:id/complete', skip: '未実装' do
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

  describe 'GET /tasks/recording', skip: '未実装' do
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

  describe 'GET /tasks/pending', skip: '未実装' do
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
