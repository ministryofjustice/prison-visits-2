# frozen_string_literal: true

module AuthHelper
  ACCESS_TOKEN = Struct.new(:access_token).new('an-access-token')

  API_PREFIX = "#{ENV.fetch('PRISON_API_HOST')}/api/v1"

  def stub_auth_token
    allow(Nomis::Oauth::TokenService).to receive(:valid_token).and_return(ACCESS_TOKEN)

    stub_request(:post, "#{ENV.fetch('NOMIS_OAUTH_HOST')}/auth/oauth/token?grant_type=client_credentials").
      to_return(body: {
        "access_token": ACCESS_TOKEN.access_token,
        "token_type": "bearer",
        "expires_in": 1199,
        "scope": "readwrite"
      }.to_json)
  end
end
