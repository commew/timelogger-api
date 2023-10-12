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

    context "when use another user's taskCategoryId" do
      let(:another_users_task_category) { create(:task_category) }

      let(:another_user_account) { create(:account, task_groups: [another_users_task_category.task_group]) }

      before do
        params = {
          taskGroupId: another_user_account.task_groups.first.id,
          taskCategoryId: another_users_task_category.id,
          status: Task::STATUS[:recording]
        }

        post '/tasks', params:, headers: headers(account)
      end

      it 'returns http bad request' do
        expect(response).to have_http_status(422)
      end

      it 'returns appropriate title' do
        expect(JSON.parse(response.body)['title']).to eq 'Unprocessable Entity.'
      end

      it 'returns appropriate type' do
        expect(JSON.parse(response.body)['type']).to eq 'UNPROCESSABLE_ENTITY'
      end

      it 'returns appropriate error name' do
        expect(JSON.parse(response.body)['invalidParams'].first['name']).to eq 'task_category'
      end

      it 'returns appropriate error reason' do
        expect(JSON.parse(response.body)['invalidParams'].first['reason'])
          .to eq Task::TASK_CATEGORY_ACCOUNT_ERROR_MESSAGE
      end
    end

    context 'when taskCategoryId is empty' do
      before do
        params = {
          taskGroupId: account.task_groups.first.id,
          status: Task::STATUS[:recording]
        }

        post '/tasks', params:, headers: headers(account)
      end

      it 'returns http bad request' do
        expect(response).to have_http_status(422)
      end

      it 'returns appropriate error name' do
        expect(JSON.parse(response.body)['invalidParams'].first['name']).to eq 'task_category'
      end

      it 'returns appropriate error reason' do
        expect(JSON.parse(response.body)['invalidParams'].first['reason']).to eq 'must exist'
      end
    end
  end

  describe 'PATCH /tasks/:id/stop' do
    let(:task_category) { create(:task_category) }

    let(:account) { create(:account, task_groups: [task_category.task_group]) }

    let(:task) { Task.start_recording(task_category, Time.zone.now, account) }

    context 'when task exists' do
      before do
        patch "/tasks/#{task.id}/stop", headers: headers(account)
      end

      it 'returns http ok' do
        expect(response).to have_http_status 200
      end

      it 'returns empty json' do
        expect(response.body).to eq('{}')
      end
    end

    context 'when task not exists' do
      before do
        patch '/tasks/0/stop', headers: headers(account)
      end

      it 'returns http not found' do
        expect(response).to have_http_status 404
      end
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

  describe 'GET /tasks/recording' do
    let(:account) { create(:account) }

    before do
      get '/tasks/recording', headers: headers(account)
    end

    context 'when recording tasks not exists' do
      before do
        # 記録中のタスク、ただしほかのアカウントの
        create(
          :task,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00' }
            ]
          )
        )

        get '/tasks/recording', headers: headers(account)
      end

      it 'returns http ok' do
        expect(response).to have_http_status(200)
      end

      it 'returns empty list' do
        expect(JSON.parse(response.body)).to eq({ 'tasks' => [] })
      end
    end

    context 'when 2 recording tasks and 2 other tasks exists' do
      let(:task_group) { create(:task_group, account:) }
      let(:task_category) { create(:task_category, task_group:) }
      let(:task_category2) { create(:task_category, task_group:) }

      before do
        # 終了したタスク
        create(
          :task,
          completed: true,
          task_category:,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' }
            ]
          )
        )

        # 停止中のタスク
        create(
          :task,
          task_category:,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' }
            ]
          )
        )

        # 記録中のタスク、計測は1回目
        create(
          :task,
          task_category:,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00' }
            ]
          )
        )

        # 記録中のタスク、計測は2回目
        create(
          :task,
          task_category: task_category2,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' },
              { start_at: '2023-01-01 10:20:00' }
            ]
          )
        )

        # 記録中のタスク、ただしほかのアカウントの
        create(
          :task,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00' }
            ]
          )
        )

        get '/tasks/recording', headers: headers(account)
      end

      it 'returns http ok' do
        expect(response).to have_http_status(200)
      end

      it 'returns 2 tasks' do
        expect(JSON.parse(response.body)['tasks'].count).to eq(2)
      end

      it 'returns task id' do
        expect(JSON.parse(response.body)['tasks'][0]['id']).not_to be_nil
      end

      it 'returns appropriate task status' do
        expect(JSON.parse(response.body)['tasks'][0]['status']).to eq(Task::STATUS[:recording].to_s)
      end

      it 'returns appropriate task startAt' do
        expect(JSON.parse(response.body)['tasks'][0]['startAt']).to eq('2023-01-01T10:00:00Z')
      end

      it 'returns task endAt as null' do
        expect(JSON.parse(response.body)['tasks'][0]['endAt']).to eq('0000-00-00T00:00:00Z')
      end

      it 'returns appropriate task duration' do
        expect(JSON.parse(response.body)['tasks'][0]['duration']).to eq(0)
      end

      it 'returns appropriate taskGroupId' do
        expect(JSON.parse(response.body)['tasks'][0]['taskGroupId']).to be(task_category.task_group.id)
      end

      it 'returns appropriate taskCategoryId' do
        expect(JSON.parse(response.body)['tasks'][0]['taskCategoryId']).to be(task_category.id)
      end

      it 'returns task id for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['id']).not_to be_nil
      end

      it 'returns appropriate task status for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['status']).to eq(Task::STATUS[:recording].to_s)
      end

      it 'returns appropriate task startAt for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['startAt']).to eq('2023-01-01T10:00:00Z')
      end

      it 'returns task endAt as null for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['endAt']).to eq('0000-00-00T00:00:00Z')
      end

      it 'returns appropriate task duration for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['duration']).to eq(10 * 60)
      end

      it 'returns appropriate taskGroupId for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['taskGroupId']).to be(task_category2.task_group.id)
      end

      it 'returns appropriate taskCategoryId for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['taskCategoryId']).to be(task_category2.id)
      end
    end
  end

  describe 'GET /tasks/pending' do
    let(:account) { create(:account) }

    before do
      get '/tasks/pending', headers: headers(account)
    end

    context 'when pending tasks not exists' do
      before do
        # 停止中のタスク、ただしほかのアカウントの
        create(
          :task,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' }
            ]
          )
        )

        get '/tasks/pending', headers: headers(account)
      end

      it 'returns http ok' do
        expect(response).to have_http_status(200)
      end

      it 'returns empty list' do
        expect(JSON.parse(response.body)).to eq({ 'tasks' => [] })
      end
    end

    context 'when 2 pending tasks and 2 other tasks exists' do
      let(:task_group) { create(:task_group, account:) }
      let(:task_category) { create(:task_category, task_group:) }
      let(:task_category2) { create(:task_category, task_group:) }

      before do
        # 記録中のタスク
        create(
          :task,
          task_category:,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' },
              { start_at: '2023-01-01 10:20:00' }
            ]
          )
        )

        # 終了したタスク
        create(
          :task,
          completed: true,
          task_category:,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' }
            ]
          )
        )

        # 停止中のタスク、計測は1回
        create(
          :task,
          task_category:,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' }
            ]
          )
        )

        # 停止中のタスク、計測は2回
        create(
          :task,
          task_category: task_category2,
          task_time_units: TaskTimeUnit.create(
            [
              { start_at: '2023-01-01 10:00:00', end_at: '2023-01-01 10:10:00' },
              { start_at: '2023-01-01 10:20:00', end_at: '2023-01-01 10:40:00' }
            ]
          )
        )

        get '/tasks/pending', headers: headers(account)
      end

      it 'returns http ok' do
        expect(response).to have_http_status(200)
      end

      it 'returns 2 tasks' do
        expect(JSON.parse(response.body)['tasks'].count).to eq(2)
      end

      it 'returns task id' do
        expect(JSON.parse(response.body)['tasks'][0]['id']).not_to be_nil
      end

      it 'returns appropriate task status' do
        expect(JSON.parse(response.body)['tasks'][0]['status']).to eq(Task::STATUS[:pending].to_s)
      end

      it 'returns appropriate task startAt' do
        expect(JSON.parse(response.body)['tasks'][0]['startAt']).to eq('2023-01-01T10:00:00Z')
      end

      it 'returns task endAt as null' do
        expect(JSON.parse(response.body)['tasks'][0]['endAt']).to eq('2023-01-01T10:10:00Z')
      end

      it 'returns appropriate task duration' do
        expect(JSON.parse(response.body)['tasks'][0]['duration']).to eq(10 * 60)
      end

      it 'returns appropriate taskGroupId' do
        expect(JSON.parse(response.body)['tasks'][0]['taskGroupId']).to be(task_category.task_group.id)
      end

      it 'returns appropriate taskCategoryId' do
        expect(JSON.parse(response.body)['tasks'][0]['taskCategoryId']).to be(task_category.id)
      end

      it 'returns task id for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['id']).not_to be_nil
      end

      it 'returns appropriate task status for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['status']).to eq(Task::STATUS[:pending].to_s)
      end

      it 'returns appropriate task startAt for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['startAt']).to eq('2023-01-01T10:00:00Z')
      end

      it 'returns task endAt as null for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['endAt']).to eq('2023-01-01T10:40:00Z')
      end

      it 'returns appropriate task duration for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['duration']).to eq(30 * 60)
      end

      it 'returns appropriate taskGroupId for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['taskGroupId']).to be(task_category2.task_group.id)
      end

      it 'returns appropriate taskCategoryId for second task' do
        expect(JSON.parse(response.body)['tasks'][1]['taskCategoryId']).to be(task_category2.id)
      end
    end
  end
end
