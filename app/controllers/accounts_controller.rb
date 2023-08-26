class AccountsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  skip_before_action :authenticate, only: [:create]

  http_basic_authenticate_with(
    name: Rails.application.config_for(:auth)[:basic_authenticate_user],
    password: Rails.application.config_for(:auth)[:basic_authenticate_password],
    only: :create
  )

  def index
    render json: account_hash(@account), status: :ok
  end

  def create
    begin
      if (account = Account.create_with_open_id_provider(**account_params.to_h.symbolize_keys)).invalid?
        return render_validation_errored account
      end
    rescue ActiveRecord::RecordNotUnique
      return render_account_already_exists
    end

    render json: account_hash(account), status: :created
  end

  private

  def account_params
    params.permit(:sub, :provider)
  end

  def render_account_already_exists
    render json: {
      type: 'BAD_REQUEST',
      title: 'Bad Request.',
      detail: 'Account already exists.'
    }, status: :bad_request
  end

  def render_validation_errored(account)
    render json: {
      type: 'UNPROCESSABLE_ENTITY',
      title: 'Unprocessable Entity.',
      invalidParams: account.open_id_providers.first.errors.map do |error|
        {
          name: error.attribute,
          reason: error.message
        }
      end
    }, status: :unprocessable_entity
  end

  def account_hash(account)
    {
      id: account.id,
      openIdProviders: [
        {
          sub: account.open_id_providers.first.sub,
          provider: account.open_id_providers.first.provider
        }
      ]
    }
  end
end
