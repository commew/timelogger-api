class ApplicationController < ActionController::API
  before_action :authenticate

  private

  def authenticate
    begin
      decoded_token = decode_jwt_token
    rescue JWT::DecodeError => e
      # 想定しているのは、tokenがおかしいことによるエラーのみ。
      # この場合に発生するのはJWT::DecodeErrorで、たとえばsecretがおかしい場合の
      # JWT::VerificationErrorはrethrowする。
      throw e if e.class != JWT::DecodeError

      return render_unauthorized e.message
    end

    @account = Account.retrieve_by_open_id_provider decoded_token[0][:sub], decoded_token[0][:provider]
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
