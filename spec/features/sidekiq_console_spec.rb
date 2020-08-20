require "rails_helper"

RSpec.feature 'Sidekiq Admin Console' do
  include ActiveJobHelper

  let(:prison) { create :prison }

  describe 'When logged in as an admin', :sidekiq do
    before do
      prison_login [Struct.new(:sso_organisation_name).new(EstateSSOMapper::DIGITAL_ORG), prison.estate]
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
