require 'base64'

module JWTHelper
  def generate_jwt_token(options = {})
    payload = {
      'internal_user': false,
      'scope': %w[read write],
      'exp': 4.hours.from_now.to_i,
      'client_id': 'pvb'
    }.merge(options)

    rsa_private = OpenSSL::PKey::RSA.generate 2048
    rsa_public = Base64.strict_encode64(rsa_private.public_key.to_s)

    allow(Rails.configuration).to receive(:nomis_oauth_public_key).and_return(rsa_public)

    JWT.encode payload, rsa_private, 'RS256'
  end
end
