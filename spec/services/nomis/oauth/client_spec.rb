require 'rails_helper'
require 'base64'

RSpec.describe Nomis::Oauth::Client do
  describe '#post' do
    let(:auth_header) do
      'Basic bXlfY2xpZW50X2lkOmFfdmFsdWVfbGlrZV8+Pj5fdGhhdF9iYXNlNjRfZW5jb2Rlc193aXRoX3BsdXNfb3Jfc2xhc2g='
    end

    describe 'with a valid request' do
      let(:client_id) { 'my_client_id' }
      let(:client_secret) { 'a_value_like_>>>_that_base64_encodes_with_plus_or_slash' }

      before do
        allow(Rails.configuration).to receive(:nomis_oauth_client_id).and_return(client_id)
        allow(Rails.configuration).to receive(:nomis_oauth_client_secret).and_return(client_secret)
      end

      it 'sets the Authorization header' do
        WebMock.stub_request(:post, /\w/).to_return(body: '{}')

        api_host = Rails.configuration.nomis_oauth_host
        route = '/auth/oauth/token?grant_type=client_credentials'
        client = described_class.new(api_host)

        client.post(route)

        expect(WebMock).to have_requested(:post, /\w/)
            .with(
              headers: {
                Authorization: auth_header
              }
            )
      end
    end
  end

  describe '#get' do
    it 'does not set the Authorization header' do
      WebMock.stub_request(:get, /\w/).to_return(body: '{}')

      api_host = Rails.configuration.nomis_oauth_host
      route = '/auth/.well-known/jwks.json'
      client = described_class.new(api_host)

      client.get(route)

      expect(WebMock).to have_requested(:get, /\w\/auth\/.well-known\/jwks.json/)
        .with { |request| expect(request.headers).not_to include('Authorization') }
    end
  end
end
