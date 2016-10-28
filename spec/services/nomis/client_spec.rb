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

  it 'raises an APIError if an unexpected exception is raised containing request information' do
    WebMock.stub_request(:get, /\w/).
      to_raise(Excon::Errors::Timeout.new('Request Timeout'))
    expect {
      subject.get(path, params)
    }.to raise_error(Nomis::APIError, 'Exception Excon::Errors::Timeout calling GET /nomisapi/lookup/active_offender: Request Timeout')
  end

  describe 'with auth configured' do
    let(:client_token) { 'atoken' }
    let(:client_key) {
      key = 'MHcCAQEEIGSsQrYsGnRCEYDNmdXxzBQ8Tq4SpfVWvr5ROPWM29cxoAoGCCqGSM49AwEHoUQDQgAEQ9qVQgr2XA8nupSP7C67pvufywLc2ur11b3bYe7t6+mGAWYM9Pd/L49cI6HWnPVg5UPr1PC+aT4RKW6PGj6BuQ=='
      OpenSSL::PKey::EC.new(Base64.decode64(key))
    }

    it 'sends an Authorization header containing a JWT token', vcr: { cassette_name: 'client-auth' } do
      subject.get(path, params)
      expect(WebMock).to have_requested(:get, /\w/).
        with { |req|
          auth_type, token = req.headers["Authorization"].split(' ')
          next unless auth_type == 'Bearer'
          # raises an error if token is not an ES256 JWT token
          JWT.decode(token, client_key, true, algorithm: 'ES256')
          true
        }
    end
  end
end
