require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'When NOMIS API was disabled' do
  include_context 'with a process request setup'

  let(:vst) { create(:visit) }

  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'mojsso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'email' => 'joe@example.com',
        'permissions' => [
          { 'organisation' => vst.prison.estate.sso_organisation_name, roles: [] }
        ],
        'links' => {
          'profile' => 'http://example.com/profile',
          'logout' => 'http://example.com/logout'
        }
      }
    }
  end

  before do
    OmniAuth.config.add_mock(:mojsso, sso_response)
    vst.prisoner.update!(number: 'zzzzzzz')
  end

  scenario "a prisoner is not found", :expect_exception, vcr: { cassette_name: :nomis_disabled_invalid_prisoner_number } do
    visit prison_visit_path(vst, locale: 'en')

    expect(page).to have_css('h1', text: 'Check visit request')
  end
end
