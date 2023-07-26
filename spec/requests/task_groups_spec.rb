require 'rails_helper'

RSpec.describe 'TaskGroups' do
  describe 'GET /task-groups' do
    before do
      get '/task-groups'
    end

    it 'response is OK' do
      expect(response).to have_http_status(:ok)
    end

    context 'when success, inspect body schema' do
      ## 現時点での期待されるレスポンスのスキーマ
      # {
      #   "groups": [
      #     {
      #       "id": 1,
      #       "name": "仕事",
      #       "categories": [
      #         {
      #           "id": 1,
      #           "name": "会議"
      #         },
      #         {
      #           "id": 2,
      #           "name": "資料作成"
      #         }
      #       ]
      #     },
      #     {
      #       "id": 2,
      #       "name": "学習",
      #       "categories": [
      #         {
      #           "id": 3,
      #           "name": "TOEIC"
      #         }
      #       ]
      #     },
      #     {
      #       "id": 3,
      #       "name": "趣味",
      #       "categories": [
      #         {
      #           "id": 4,
      #           "name": "散歩"
      #         },
      #         {
      #           "id": 5,
      #           "name": "読書"
      #         }
      #       ]
      #     },
      #     {
      #       "id": 4,
      #       "name": "グループ未分類",
      #       "categories": [
      #         {
      #           "id": 6,
      #           "name": "移動・外出"
      #         }
      #       ]
      #     }
      #   ]
      # }
      let(:result) { JSON.parse(response.body) }
      let(:top_level_keys) { result.keys }
      let(:categories_keys) { result[top_level_keys.first].first['categories'].first.keys }
      let(:second_level_keys) { result[top_level_keys.first].first.keys }

      it 'top level keys is ["groups"]' do
        expect(top_level_keys).to eq(['groups'])
      end

      it 'second level keys is ["id", "name", "categories"]' do
        expect(second_level_keys).to eq(%w[id name categories])
      end

      it 'categories keys is ["id", "name"]' do
        expect(categories_keys).to eq(%w[id name])
      end
    end
  end
end
