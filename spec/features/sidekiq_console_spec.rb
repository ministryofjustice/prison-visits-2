require "rails_helper"

RSpec.feature 'Sidekiq Admin Console' do
  include ActiveJobHelper

  let(:prison) { create :prison }
  let(:email_address) { 'joe@example.com' }

  describe 'When logged in as an admin', :sidekiq do
    before do
      prison_login [Struct.new(:nomis_id).new('WED'), prison.estate], email_address, [SignonIdentity::ADMIN_ROLE]
      stub_auth_token
      stub_request(:get, "https://api-dev.prison.service.justice.gov.uk/api/staff/485926/emails").
          to_return(body: [email_address].to_json)
      visit prison_inbox_path
    end

    scenario "with an user part of the moj.noms.digital organisation it is accessible" do
      visit sidekiq_web_path

      expect(page).to have_link 'Sidekiq'
    end
  end

  scenario "when not logged in" do
    expect {
      visit sidekiq_web_path
    }.to raise_error(ActionController::RoutingError)

    expect(page).not_to have_link 'Sidekiq'
  end
end
