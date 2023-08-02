require 'rails_helper'

RSpec.describe 'TaskGroups' do
  # ここでは正常系のみテストをする
  describe 'GET /task-groups' do
    before do
      get '/task-groups'
    end

    it 'response is OK' do
      expect(response).to have_http_status(200)
    end

    context 'when success, inspect body schema' do
      let(:result) { JSON.parse(response.body) }
      # 本来は authorization で account を特定するが、
      # 現在は未実装なのでこのようにテストを書いている
      let(:account) { Account.first }
      # as_json の返す値の正しさは、TaskGroup, TaskCatetory でのテスト対象
      let(:expected) {
        {
          "groups" => account.task_groups.as_json
        }
      }

      it 'returns expected hash.' do
        expect(result).to eq(expected)
      end
    end
  end
end
