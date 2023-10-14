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

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  # letが多いが、いずれも必要なため
  describe 'PATCH /tasks/:id/stop' do
    let(:task_category) { create(:task_category) }

    let(:account) { create(:account, task_groups: [task_category.task_group]) }

    let(:now) { Time.zone.now.change(usec: 0) }

    let(:before_30_minutes) { now - 30.minutes }

    let(:task) { Task.start_recording(task_category, before_30_minutes, account) }

    context 'when task exists' do
      before do
        travel_to now

        patch "/tasks/#{task.id}/stop", headers: headers(account)
      end

      it 'returns http ok' do
        expect(response).to have_http_status 200
      end

      it 'returns task id' do
        expect(JSON.parse(response.body)['id']).to eq task.id
      end

      it 'returns pending as status' do
        expect(JSON.parse(response.body)['status']).to eq Task::STATUS[:pending].to_s
      end

      it 'returns current time as startAt' do
        expect(JSON.parse(response.body)['startAt']).to eq before_30_minutes.rfc3339
      end

      it 'returns now as endAt' do
        expect(JSON.parse(response.body)['endAt']).to eq now.rfc3339
      end

      it 'returns 30 minutes as duration' do
        expect(JSON.parse(response.body)['duration']).to be 30 * 60
      end

      it 'returns task group id' do
        expect(JSON.parse(response.body)['taskGroupId']).to be task.task_category.task_group.id
      end

      it 'returns task category id' do
        expect(JSON.parse(response.body)['taskCategoryId']).to be task.task_category.id
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

    context 'when task already stopped' do
      let(:task_already_stopped) do
        Task.start_recording(task_category, before_30_minutes, account).tap(&:make_pending)
      end

      before do
        patch "/tasks/#{task_already_stopped.id}/stop", headers: headers(account)
      end

      it 'returns http bad request' do
        expect(response).to have_http_status 400
      end

      it 'returns appropriate type' do
        expect(JSON.parse(response.body)['type']).to eq 'INVALID_STATUS_TRANSITION'
      end

      it 'returns appropriate title' do
        expect(JSON.parse(response.body)['title']).to eq 'Invalid status transition.'
      end

      it 'returns appropriate detail' do
        expect(JSON.parse(response.body)['detail']).to eq 'Task status is pending, could not make status pending.'
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe 'PATCH /tasks/:id/start' do
    let(:task_category) { create(:task_category) }

    let(:account) { create(:account, task_groups: [task_category.task_group]) }

    let(:now) { Time.zone.now.change(usec: 0) }

    let(:before_30_minutes) { now - 30.minutes }

    let(:task) { Task.start_recording(task_category, before_30_minutes, account).tap(&:make_pending) }

    context 'when task exists' do
      before do
        travel_to now

        patch "/tasks/#{task.id}/start", headers: headers(account)
      end

      it 'returns http ok' do
        expect(response).to have_http_status 200
      end

      it 'returns task id' do
        expect(JSON.parse(response.body)['id']).to eq task.id
      end

      it 'returns pending as status' do
        expect(JSON.parse(response.body)['status']).to eq Task::STATUS[:recording].to_s
      end

      it 'returns current time as startAt' do
        expect(JSON.parse(response.body)['startAt']).to eq before_30_minutes.rfc3339
      end

      it 'returns nil as endAt' do
        expect(JSON.parse(response.body)['endAt']).to eq '0000-00-00T00:00:00Z'
      end

      it 'returns 30 minutes as duration' do
        expect(JSON.parse(response.body)['duration']).to be 30 * 60
      end

      it 'returns task group id' do
        expect(JSON.parse(response.body)['taskGroupId']).to be task.task_category.task_group.id
      end

      it 'returns task category id' do
        expect(JSON.parse(response.body)['taskCategoryId']).to be task.task_category.id
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

    context 'when task already started' do
      let(:task_already_started) do
        Task.start_recording(task_category, before_30_minutes, account)
      end

      before do
        patch "/tasks/#{task_already_started.id}/start", headers: headers(account)
      end

      it 'returns http bad request' do
        expect(response).to have_http_status 400
      end

      it 'returns appropriate type' do
        expect(JSON.parse(response.body)['type']).to eq 'INVALID_STATUS_TRANSITION'
      end

      it 'returns appropriate title' do
        expect(JSON.parse(response.body)['title']).to eq 'Invalid status transition.'
      end

      it 'returns appropriate detail' do
        expect(JSON.parse(response.body)['detail']).to eq 'Task status is recording, could not make status recording.'
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe 'PATCH /tasks/:id/complete' do
    let(:task_group) { create(:task_group) }
    let(:task_category) { create(:task_category, task_group:, name: 'その他') }

    before do
      patch "/tasks/#{task.id}/complete", headers:
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
          duration
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

    context 'when task not exists' do
      let(:task) { build(:task, id: 0) }

      it 'returns 404.' do
        expect(response).to have_http_status(404)
      end
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
