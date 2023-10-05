require 'rails_helper'

# 仮りで全てのエンドポイントを定義し、正常に応答することだけ確認
RSpec.describe 'Tasks' do
  describe 'POST /tasks' do
    let(:task_category) { create(:task_category) }

    let(:account) { create(:account, task_groups: [task_category.task_group]) }

    context 'when task created' do
      let(:now) { Time.zone.now }

      before do
        params = {
          taskGroupId: task_category.task_group.id,
          taskCategoryId: task_category.id,
          status: Task::STATUS[:recording]
        }

        travel_to now

        post '/tasks', params:, headers: headers(account)
      end

      it 'returns http created' do
        expect(response).to have_http_status(201)
      end

      it 'returns task id' do
        expect(JSON.parse(response.body)['id']).not_to be_nil
      end

      it 'returns recording as status' do
        expect(JSON.parse(response.body)['status']).to eq Task::STATUS[:recording].to_s
      end

      it 'returns current time as startAt' do
        expect(JSON.parse(response.body)['startAt']).to eq now.rfc3339
      end

      it 'returns nil as endAt' do
        expect(JSON.parse(response.body)['endAt']).to eq '0000-00-00T00:00:00Z'
      end

      it 'returns 0 as duration' do
        expect(JSON.parse(response.body)['duration']).to be 0
      end

      it 'returns task group id' do
        expect(JSON.parse(response.body)['taskGroupId']).to be task_category.task_group.id
      end

      it 'returns task category id' do
        expect(JSON.parse(response.body)['taskCategoryId']).to be task_category.id
      end
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
