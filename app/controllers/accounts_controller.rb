class AccountsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.credentials.http_basic_authenticate.user,
    password: Rails.application.credentials.http_basic_authenticate.password,
    only: :create
  )

  def create
    begin
      if (account = Account.create_with_open_id_provider(params['sub'], params['provider'])).invalid?
        return render_validation_errored account
      end
    rescue ActiveRecord::RecordNotUnique
      return render_account_already_exists
    end

    render_created account
  end

  private

  def render_created(account)
    render json: {
      id: account.id,
      openIdProviders: [
        {
          sub: account.open_id_providers.first.sub,
          provider: account.open_id_providers.first.provider
        }
      ]
    }, status: :created
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
end
