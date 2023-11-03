require 'base64'

module JwtHelper
  def generate_jwt_token(options = {})
    payload = {
      'internal_user': false,
      'scope': %w[read write],
      'exp': 4.hours.from_now.to_i,
      'client_id': 'pvb'
    }.merge(options)

    rsa_private = OpenSSL::PKey::RSA.generate 2048

    JWT.encode payload, rsa_private, 'RS256'
  end
end
