require 'rails_helper'

RSpec.describe 'Sidekiq Admin Console' do
  let(:prison) { create :prison }
  let(:email_address) { 'joe@example.com' }

  describe 'When logged in as an admin', :sidekiq do
    before do
      prison_login [Struct.new(:nomis_id).new('WED'), prison.estate], email_address, [SignonIdentity::ADMIN_ROLE]
      stub_auth_token
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/staff/485926/emails").
          to_return(body: [email_address].to_json)
      get prison_inbox_path

      follow_redirect! while response.redirect?
    end

    context 'with an user part of the moj.noms.digital organisation it is accessible' do
      it 'responds with 200' do
        get sidekiq_web_path

        expect(response.status).to eq(200)
        expect(response.body).to include('Sidekiq')
      end
    end
  end

  describe 'when not logged in' do
    it 'raises ActionController::RoutingError' do
      expect {
        get sidekiq_web_path
      }.to raise_error(ActionController::RoutingError)

      expect(response).to be_nil
    end
  end
end
