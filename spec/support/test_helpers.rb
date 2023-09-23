module TestHelpers
  def headers(account = nil)
    account ||= create(:account)

    token = JWT.encode(
      {
        sub: account.open_id_providers.first.sub,
        provider: account.open_id_providers.first.provider,
        jti: ''
      },
      Rails.application.config_for(:auth)[:jwt_hmac_secret]
    )

    {
      Authorization: "Bearer #{token}"
    }
  end
end
