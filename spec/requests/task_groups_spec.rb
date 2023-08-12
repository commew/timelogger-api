require 'rails_helper'

RSpec.describe 'TaskGroups' do
  # ここでは正常系のみテストをする
  describe 'GET /task-groups' do
    context 'an account exists, the account was created using "Account.create_with_open_id_provider"' do
      let(:open_id_provider) { build :open_id_provider }
      # 引数が長くなるのを避けるための要約変数
      let(:sub) { open_id_provider.sub }
      let(:provider) { open_id_provider.provider }
      let!(:account) { Account.create_with_open_id_provider sub, provider }
      let(:headers) {
        token = JWT.encode(
          { sub:, provider: },
          Rails.application.credentials.jwt_hmac_secret
        )
        {
          Authorization: "Bearer #{token}"
        }
      }
      before do
        # Account.create_with_open_id_provider open_id_provider.as_json
        get '/task-groups', headers:
      end

      it 'response is OK' do
        expect(response).to have_http_status(200)
      end

      context 'when success, inspect body schema' do
        let(:result) { JSON.parse(response.body) }
        # 本来は authorization で account を特定するが、
        # as_json の返す値の正しさは、TaskGroup, TaskCatetory でのテスト対象
        let(:expected) do
          {
            'groups' => account.task_groups.as_json
          }
        end

        it 'returns expected hash.' do
          expect(result).to eq(expected)
        end
      end

      context 'other account was created, without using Account.create_with_open_id_provider: it means new account has no task_groups' do
        let(:open_id_provider) { build :open_id_provider, sub: '888888888888888888888' }
        let!(:account) { create :account, open_id_providers: [open_id_provider] }
        # 引数が長くなるのを避けるための要約変数
        let(:sub) { open_id_provider.sub }
        let(:provider) { open_id_provider.provider }
        let(:headers) {
          token = JWT.encode(
            { sub:, provider: },
            Rails.application.credentials.jwt_hmac_secret
          )
          {
            Authorization: "Bearer #{token}"
          }
        }
        it 'response is OK' do
          expect(response).to have_http_status(200)
        end
        
        let(:result) { JSON.parse(response.body) }
        let(:expected) {
          {
            'groups' => []
          }
        }
        it 'returns expected hash.' do
          expect(result).to eq(expected)
        end
      end
    end
  end
end
