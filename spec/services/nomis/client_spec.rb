require 'rails_helper'

RSpec.describe Nomis::Client do
  subject { described_class.new(api_host) }

  let(:api_host) { Rails.configuration.prison_api_host }

  let(:path) { 'v1/lookup/active_offender' }
  let(:params) {
    {
      noms_id: 'G7244GR',
      date_of_birth: Date.parse('1966-11-22')
    }
  }

  describe 'with a valid request', vcr: { cassette_name: 'client-request-id' } do
    it 'sets the X-Request-Id header if a request_id is present' do
      RequestStore.store[:request_id] = 'uuid'
      subject.get(path, params)
      expect(WebMock).to have_requested(:get, /\w/)
        .with(headers: { 'X-Request-Id' => 'uuid' })
    end
  end

  context 'when there is an http status error' do
    let(:error) do
      Excon::Error::HTTPStatus.new('error',
                                   double('request'),
                                   double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError', :expect_exception do
      expect { subject.get(path, params) }
        .to raise_error(Nomis::APIError, 'Unexpected status 422 calling GET /api/v1/lookup/active_offender: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(PVB::ExceptionHandler).to receive(:capture_exception).with(error, fingerprint: %w[nomis excon])

      expect { subject.get(path, params) }.to raise_error(Nomis::APIError)
    end
  end

  context 'when there is a timeout' do
    before do
      WebMock.stub_request(:get, /\w/).to_timeout
    end

    it 'raises an Nomis::TimeoutError if a timeout occurs', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError)
    end
  end

  context 'when there is an unexpected exception' do
    let(:error) do
      Excon::Errors::SocketError.new(StandardError.new('Socket error'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError)
    end
  end

  describe 'with an error' do
    let(:error) do
      Excon::Error::HTTPStatus.new('error',
                                   double('request'),
                                   double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError, 'Unexpected status 422 calling GET /api/v1/lookup/active_offender: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(PVB::ExceptionHandler).to receive(:capture_exception).with(error, fingerprint: %w[nomis excon])

      expect { subject.get(path, params) }.to raise_error(Nomis::APIError)
    end

    it 'increments the api error count', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError)
        .and change { PVB::Instrumentation.custom_log_items[:api_request_count] }.from(nil).to(1)
    end
  end

  describe 'with auth configured' do
    let(:access_token) do
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRwcy1jbGllbnQta2V5In0.eyJzdWIiOiJ0' \
      'ZXN0IiwiZ3JhbnRfdHlwZSI6ImNsaWVudF9jcmVkZW50aWFscyIsInNjb3BlIjpbInJlYWQiLCJ3cml0' \
      'ZSJdLCJhdXRoX3NvdXJjZSI6Im5vbmUiLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjkwOTAvYXV0aC9p' \
      'c3N1ZXIiLCJleHAiOjE2Nzg0NjY3MTEsImp0aSI6IkRIbnY3ZElCSFdjdmh6akdlTFotZFlGSndGMCIs' \
      'ImNsaWVudF9pZCI6InRlc3QifQ.QLYRxudeQeh_54fJmMNevmHrt2d6hci6qqbqskPt41hvFWCLOrA4T' \
      'LJSkRsu-u3l1grZKpWJWKUlI0v51BnjnzkJ8oJBUQ738qILpN_lZixxxP1QB2sqL-tO2NgXW3H2-HPvJ' \
      'muUWABr5WBbzEbCvy9xMQhlMGN3BAi-EbbOmAjzP53194ggcojHz2tlAfav6Z8qSc1BKeSrMRVq6cA42' \
      'xLER61URCSAYfjRa_wTlFALi-K7CKdsD2T8zsO2H8kBxDx5nJN_5beMPCFkKLN66NAEtiAfEgHZE9ri4' \
      '7gWVC1gPrm6-S6CoIGu54KNQ6hF8rsntFeFvPr1ff8WrRgOtg'
    end

    let(:config) do
      {
        nomis_oauth_host: 'http://localhost:9090',
        nomis_oauth_client_id: 'test',
        nomis_oauth_client_secret: '6+9tp<TO4b0!s)>>hSA.Kq7Rjtab.6V9P-lW*TZIW:2nj8>u&2F&>snY5G9v'
      }
    end

    before do
      config.each do |key, val|
        allow(Rails.configuration).to receive(key).and_return(val)
      end

      stub_request(:post, 'http://localhost:9090/auth/oauth/token?grant_type=client_credentials')
        .to_return(
          body: {
            access_token: access_token,
            token_type: 'bearer',
            expires_in: 3599,
            scope: 'read write',
            sub: 'test',
            auth_source: 'none',
            jti: 'DHnv7dIBHWcvhzjGeLZ-dYFJwF0',
            iss: 'http://localhost:9090/auth/issuer'
          }.to_json
        )
    end

    it 'sends an Authorization header containing a JWT token', vcr: { cassette_name: 'client-auth' } do
      subject.get(path, params)
      expect(WebMock).to have_requested(:get, /\w/)
        .with { |req|
          auth_type, token = req.headers["Authorization"].split(' ')
          next unless auth_type == 'Bearer'

          expect(token).to eq(access_token)
        }
    end
  end
end
