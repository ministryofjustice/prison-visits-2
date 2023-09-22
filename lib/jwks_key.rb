class JwksKey
  class << self
    def openssl_public_key
      n = jwks_key_data.fetch('n')
      e = jwks_key_data.fetch('e')

      data_sequence = OpenSSL::ASN1::Sequence([OpenSSL::ASN1::Integer(base64_to_long(n)),
                                               OpenSSL::ASN1::Integer(base64_to_long(e))])
      asn1 = OpenSSL::ASN1::Sequence(data_sequence)
      OpenSSL::PKey::RSA.new(asn1.to_der)
    end

    def jwks_key_data
      return @jwks_key_data if @jwks_key_data.present?

      @jwks_key_data = HmppsApi::Oauth::Api.fetch_jwks_keys.fetch('keys').fetch(0)
    end

    def clear_jwks_key_data_cache!
      @jwks_key_data = nil
    end

  private

    def base64_to_long(data)
      decoded_with_padding = Base64.urlsafe_decode64(data) + Base64.decode64('==')
      decoded_with_padding.to_s.unpack('C*').map { |byte|
        byte < 16 ? "0#{byte.to_s(16)}" : byte.to_s(16)
      }.join.to_i(16)
    end
  end
end
