require 'rails_helper'

RSpec.describe Nomis::Oauth::JwksService do
  subject { described_class.instance }

  describe '#fetch_keys' do
    it 'returns jwks keys as JSON array', vcr: { cassette_name: 'nomis_oauth_jwks' } do
      expect(subject.fetch_keys).to eq(
        "keys" => [{
          "kty" => "RSA",
          "e" => "ABQ",
          "use" => "sig",
          "kid" => "user-kid",
          "alg" => "RS256",
          "n" => "ZII/AvQAeYSKRaa77rvYP2U+8XrP4Tk0nN0gRE2i+pBqT1wNh1f3gDvdRAa5QZzQc9xY7tKD2WiTYaITjlC+hXObvQaYfsEZtZG+zd5pTtcf96ck0j44c9bdwQ23T9nKgWTMwA=="
        }]
      )
    end
  end
end
