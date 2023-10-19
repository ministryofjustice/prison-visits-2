require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request - Acceptance with the contact list enabled', :js, :expect_exception do
  include ActiveJobHelper

  include_context 'with a process request setup'

  # When re-recording this test there was an issue with the visit slots for Leeds in T3.  Therefore, for this spec we are
  # going to use The Verne as there are bookable slots at this prison.

  let(:prison) do
    create(:prison,
           name: 'The Verne',
           email_address: prison_email_address,
           estate: create(:estate, nomis_id: 'VEI')
    )
  end
  let(:prisoner_number) { 'G4315UW' }
  let(:prisoner_dob) { '03-05-1964' }
  let(:visitor_details) { 'BYNCEILOR MAURANIE - 30/09/1967' }
  let(:nomis_comments) { 'This is a comment to be added to Nomis' }
  let(:visitor) { vst.visitors.first }

  # If re-recording the VCR cassettes in this spec then you will need to initially comment out this around to block,
  # and then update the date to match when they were recorded
  around do |ex|
    travel_to(Time.zone.local(2020, 9, 8, 13, 19, 0)) { ex.run }
  end

  before do
    vst.update!(slot_option_0: '2020-10-20T14:00/16:00')
  end

  scenario 'accepting a booking', vcr: { cassette_name: :process_happy_path } do
    # Create the visit before we go to the inbox
    vst

    visit prison_inbox_path
    # The most recent requested visit
    all('tr:not(.hidden-row)').last.click_link('View')

    expect(page).to have_css('form h1', text: 'Check visit request')
    expect(page).to have_css('form .bold-small', text: "The prisoner date of birth, prisoner number and prison name have been verified.")
    expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')

    choose_date

    fill_in 'Reference number', with: '12345678'
    fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

    click_button 'Process'

    within "#visitor_#{visitor.id}" do
      expect(page).to have_css('.error-message', text: "Process this visitor to continue")
      select visitor_details, from: "Match to prisoner's contact list"
    end

    preview_window = window_opened_by {
      click_link 'Preview email'
    }

    within_window preview_window do
      expect(page).to have_css('p', text: /Dear #{vst.visitor_full_name}/)
      expect(page).to have_css('p', text: 'A staff message')
    end

    click_button 'Process'

    expect(page).to have_css('#content .notification', text: 'Thank you for processing the visit')

    vst.reload
    visitor.reload
    expect(vst).to be_booked
    expect(visitor.nomis_id).to eq(4_508_410)
    expect(vst.reference_no).to eq('12345678')

    expect(contact_email_address)
        .to receive_email
            .with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/)
            .and_body(/Your visit to The Verne is now successfully confirmed/)
  end

  context 'when accepting a booking but contact list fails', vcr: { cassette_name: :process_contact_list_fails } do
    before do
      simulate_api_error_for(:fetch_contact_list)
    end

    it 'is expected that the contact list is not available' do
      visit prison_visit_path(vst, locale: 'en')
      expect(page).to have_css('form .notice', text: "We can’t show the NOMIS contact list right now. Please check all visitors in NOMIS")
    end
  end
end
