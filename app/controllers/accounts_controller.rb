class AccountsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.credentials.http_basic_authenticate.user,
    password: Rails.application.credentials.http_basic_authenticate.password,
    only: :post
  )

  def post
    if (account = Account.create_with_open_id_provider(params['sub'], params['provider'])).invalid?
      return render_validation_errored account
    end

    render_created account
  end

  private

  def render_created(account)
    render json: {
      id: account.id,
      openIdProviders: [
        {
          sub: account.open_id_providers[0].sub,
          provider: account.open_id_providers[0].provider
        }
      ]
    }, status: :created
  end

  def render_validation_errored(account)
    render json: {
      type: 'UNPROCESSABLE_ENTITY',
      title: 'Unprocessable Entity.',
      invalidParams: account.open_id_providers[0].errors.map do |error|
        {
          name: error.attribute,
          reason: error.message
        }
      end
    }, status: :unprocessable_entity
  end
end
