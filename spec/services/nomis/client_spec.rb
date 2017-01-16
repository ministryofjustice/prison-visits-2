# frozen_string_literal: true
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

  describe 'with a valid request', vcr: { cassette_name: 'client-request-id' } do
    it 'sets the X-Request-Id header if a request_id is present' do
      RequestStore.store[:request_id] = 'uuid'
      subject.get(path, params)
      expect(WebMock).to have_requested(:get, /\w/).
        with(headers: { 'X-Request-Id' => 'uuid' })
    end
  end

  context 'when there is an http status error' do
    let(:error) do
      Excon::Errors::HTTPStatusError.new('error',
        double('request'),
        double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError' do
      expect { subject.get(path, params) }.
        to raise_error(Nomis::APIError, 'Unexpected status 422 calling GET /nomisapi/lookup/active_offender: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(Raven).to receive(:capture_exception).with(error, fingerprint: %w[nomis excon])

      expect { subject.get(path, params) }.to raise_error(Nomis::APIError)
    end
  end

  context 'when there is an unexpected exception' do
    let(:error) do
      Excon::Errors::Timeout.new('Request Timeout')
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information' do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError, 'Exception Excon::Errors::Timeout calling GET /nomisapi/lookup/active_offender: Request Timeout')
    end
  end

  describe 'with an error' do
    let(:error) do
      Excon::Errors::HTTPStatusError.new('error',
        double('request'),
        double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information' do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError, 'Unexpected status 422 calling GET /nomisapi/lookup/active_offender: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(Raven).to receive(:capture_exception).with(error, fingerprint: %w[nomis excon])

      expect { subject.get(path, params) }.to raise_error(Nomis::APIError)
    end

    it 'increments the api error count' do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError).
        and change { Instrumentation.custom_log_items[:api_request_count] }.from(nil).to(1)
    end
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
