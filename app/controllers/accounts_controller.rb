class AccountsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with(
    name: Rails.application.credentials.http_basic_authenticate.user,
    password: Rails.application.credentials.http_basic_authenticate.password,
    only: :post
  )

  def post
    if (account = Account.create(sub: params['sub'], provider: params['provider'])).invalid?
      return render_validation_errored account
    end

    render_created account
  end

  private

  def render_created(account)
    render json: {
      id: 1,
      openIdProviders: [
        {
          sub: account.sub,
          provider: account.provider
        }
      ]
    }, status: :created
  end

  def render_validation_errored(account)
    render json: {
      type: 'UNPROCESSABLE_ENTITY',
      title: 'Unprocessable Entity.',
      invalidParams: account.errors.map { |error| { name: error.attribute, reason: error.message } }
    }, status: :unprocessable_entity
  end
end
