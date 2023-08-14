require 'rails_helper'

RSpec.describe 'TaskGroups' do
  # ここでは正常系のみテストをする
  describe 'GET /task-groups' do
    context 'when an account exists, the account was created using "Account.create_with_open_id_provider"' do
      before do
        account # let を評価させる、let" は rubocop に怒られたのでこの方法にした
        get '/task-groups', headers:
      end

      let(:open_id_provider) { build(:open_id_provider) }
      let(:account) do
        # factory ではなく .create_with_open_id_provider により
        # TaskGroup を初期でセットする
        sub = open_id_provider.sub
        provider = open_id_provider.provider
        Account.create_with_open_id_provider sub, provider
      end
      let(:headers) do
        sub = open_id_provider.sub
        provider = open_id_provider.provider
        token = JWT.encode(
          { sub:, provider: },
          Rails.application.credentials.jwt_hmac_secret
        )
        {
          Authorization: "Bearer #{token}"
        }
      end
      # as_json の返す値の正しさは、TaskGroup, TaskCatetory でのテスト対象
      let(:expected) do
        {
          'groups' => account.task_groups.as_json
        }
      end

      it 'response is OK' do
        expect(response).to have_http_status(200)
      end

      it 'returns expected hash.' do
        result = JSON.parse(response.body)
        expect(result).to eq(expected)
      end
    end

    context 'when other account was created, which has no task_groups' do
      before do
        create(:account, open_id_providers: [open_id_provider])
        get '/task-groups', headers:
      end

      let(:open_id_provider) { build(:open_id_provider, sub: '888888888888888888888') }
      let(:headers) do
        sub = open_id_provider.sub
        provider = open_id_provider.provider
        token = JWT.encode(
          { sub:, provider: },
          Rails.application.credentials.jwt_hmac_secret
        )
        {
          Authorization: "Bearer #{token}"
        }
      end
      let(:expected) do
        {
          'groups' => []
        }
      end

      it 'response is OK' do
        expect(response).to have_http_status(200)
      end

      it 'returns expected hash.' do
        result = JSON.parse(response.body)
        expect(result).to eq(expected)
      end
    end
  end
end
