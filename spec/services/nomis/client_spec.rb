require 'rails_helper'

RSpec.describe Nomis::Client do
  let(:api_host) { Rails.configuration.nomis_api_host }
  let(:client_token) { nil }
  let(:client_key) { nil }

  let(:path) { '/lookup/active_offender' }
  let(:params) {
    {
      noms_id: 'A1459AE',
      date_of_birth: Date.parse('1976-06-12')
    }
  }

  subject { described_class.new(api_host, client_token, client_key) }

  it 'sets the X-Request-Id header if a request_id is present', vcr: { cassette_name: 'client-request-id' } do
    RequestStore.store[:request_id] = 'uuid'
    subject.get(path, params)
    expect(WebMock).to have_requested(:get, /\w/).
      with(headers: { 'X-Request-Id' => 'uuid' })
  end

  describe 'with auth configured' do
    let(:client_token) { 'atoken' }
    let(:client_key) {
      key = <<-END.gsub(/^ +/, "").chomp
        -----BEGIN RSA PRIVATE KEY-----
        MIIBOwIBAAJBAKgRAIAYi4/HbzLcrXf3H3zomuhuimXLWnhqEkCdZ5DBq7ofJpsr
        qYv1lPpQUqKhFkAORoj9+w/xM+xIcvFu8t8CAwEAAQJARnKyAf/H6GHRo8FK2WF2
        Cna6EDndu2OtLZJQylLwiYVnHs8xLZXdqcAGAv0ZMWEEt2qOBQPxbPQpEWJ6ZhB0
        cQIhANE61o8r4DgP15XNI3AYYCbjrgYgxgbKmXJtlK9Vl+f3AiEAzaKXDDGMEVOV
        MoFEqkSaIoIiOum28GBj4Soz1gSTolkCIEgDpWff5SvGoCBKXCEv8qBQC0zGqQIb
        Z5dQCjYTEtbfAiEAs/pqWbHD9iZBn0Kk5qHEhg+ABjAofZrf0GMvm1HGJYECIQDC
        QteHGErMYVksaiuQxrk8I8nbe2JP6UsCd2gyWYazkg==
        -----END RSA PRIVATE KEY-----
      END
      OpenSSL::PKey::RSA.new(key)
    }

    it 'sends an Authorization header containing a JWT token', vcr: { cassette_name: 'client-auth' } do
      subject.get(path, params)
      expect(WebMock).to have_requested(:get, /\w/).
        with { |req|
          auth_type, token = req.headers["Authorization"].split(' ')
          next unless auth_type == 'Bearer'
          JWT.decode(token, nil, false) # raises error if not a JWT token
          true
        }
    end
  end
end
