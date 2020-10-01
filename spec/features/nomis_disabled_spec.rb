require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'When NOMIS API was disabled' do
  include_context 'with a process request setup'

  let(:vst) { create(:visit) }

  before do
    prison_login [vst.prison.estate]
    vst.prisoner.update!(number: 'zzzzzzz')
  end

  scenario "a prisoner is not found", :expect_exception, vcr: { cassette_name: :nomis_disabled_invalid_prisoner_number } do
    visit prison_visit_path(vst, locale: 'en')

    expect(page).to have_css('h1', text: 'Check visit request')
  end
end
