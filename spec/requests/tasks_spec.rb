require 'rails_helper'

# 仮りで全てのエンドポイントを定義し、正常に応答することだけ確認
RSpec.describe 'Tasks' do
  describe 'POST /tasks', skip: 'not implemented yet' do
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

  describe 'PATCH /tasks/:id/complete' do
    let(:task_group) { create(:task_group) }
    let(:task_category) { create(:task_category, task_group:, name: 'その他') }

    before do
      patch "/tasks/#{task.id}/complete"
    end

    context 'when task is recording, and task has some task_time_units' do
      let(:task_time_units) do
        [
          build(:task_time_unit,
                start_at: '2023-09-09T00:00:00Z',
                end_at: '2023-09-09T01:00:00Z'),
          build(:task_time_unit,
                start_at: '2023-09-09T02:00:00Z',
                end_at: '2023-09-09T03:00:00Z')
        ]
      end
      let(:task) { create(:task, task_category:, task_time_units:) }

      it 'returns 200.' do
        expect(response).to have_http_status(200)
      end

      it 'returns expected json.' do
        result = JSON.parse(response.body)
        expected_keys = %w[
          id
          status
          startAt
          endAt
          taskGroupId
          taskCategoryId
        ]
        expect(result.keys).to eq(expected_keys)
      end

      it 'returns "startAt" param, set value from first task_time_unit.' do
        result = JSON.parse(response.body)['startAt']
        expected = task_time_units.first.start_at.rfc3339
        expect(result).to eq(expected)
      end

      it 'returns "endAt" param, set value from last task_time_unit.' do
        result = JSON.parse(response.body)['endAt']
        expected = task_time_units.last.end_at.rfc3339
        expect(result).to eq(expected)
      end
    end

    context 'when task is pending' do
      let(:task_time_units) { [build(:task_time_unit, start_at: '2023-09-09', end_at: '2023-09-10')] }
      let(:task) { create(:task, task_category:, task_time_units:) }

      it 'returns 200.' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when task is completed' do
      let(:task_time_units) { [build(:task_time_unit, start_at: '2023-09-09', end_at: '2023-09-10')] }
      let(:task) { create(:task, task_category:, task_time_units:, completed: true) }

      it 'returns 400.' do
        expect(response).to have_http_status(400)
      end
    end

    context 'when id in path parameter is not exists' do
      let(:task) { build(:task, id: 0) }

      it 'returns 400.' do
        expect(response).to have_http_status(400)
      end
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
