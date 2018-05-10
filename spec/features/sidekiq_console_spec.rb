require "rails_helper"

RSpec.feature 'Sidekiq Admin Console' do
  include ActiveJobHelper

  let(:prison) { create :prison }
  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'mojsso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'email' => 'joe@example.com',
        'permissions' => [
          { 'organisation' => EstateSSOMapper::DIGITAL_ORG, roles: [] },
          { 'organisation' => prison.estate.sso_organisation_name, roles: [] }
        ],
        'links' => {
          'profile' => 'http://example.com/profile',
          'logout' => 'http://example.com/logout'
        }
      }
    }
  end

  describe 'When logged in as an admin' do
    before do
      OmniAuth.config.add_mock(:mojsso, sso_response)
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
