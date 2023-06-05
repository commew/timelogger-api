require 'securerandom'

class AccountsController < ApplicationController
  def post
    render json: {
      id: 1,
      name: '',
      openIdProviders: {
        sub: params['sub'],
        provider: params['provider']
      }
    }, status: :created
  end
end
