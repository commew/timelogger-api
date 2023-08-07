class ApplicationController < ActionController::API
  before_action :authenticate

  private

  def authenticate
    begin
      payload = decode_jwt_token.first
    rescue JWT::DecodeError => e
      # JWT::DecodeErrorは、secretがおかしい場合のJWT::VerificationErrorなどの親
      # クラスでもあるが、ここで見たいのはJWT::DecodeError自身のみ。
      # 想定しているのは、リクエストに含まれるtokenがおかしいこと。
      # 参考: https://github.com/jwt/ruby-jwt/blob/695143655b95d843d03d4a98ca43709cbe8169b4/lib/jwt/error.rb#L8-L21
      throw e if e.class != JWT::DecodeError

      return render_unauthorized e.message
    end

    @account = Account.retrieve_by_open_id_provider payload[:sub], payload[:provider]
  end

  def decode_jwt_token
    JWT.decode jwt_token_from_request, Rails.application.credentials.jwt_hmac_secret
  end

  def jwt_token_from_request
    request.headers[:Authorization].gsub(/\ABearer /, '')
  end

  def render_unauthorized(error_message)
    render json: {
      type: 'UNAUTHENTICATED',
      title: 'Account is not authenticated.',
      detail: error_message
    }, status: :unauthorized
  end
end
