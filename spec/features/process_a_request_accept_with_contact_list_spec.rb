require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request - Acceptance with the contact list enabled', js: true do
  include ActiveJobHelper

  include_context 'with a process request setup'

  let(:prison) do
    create(:prison,
      name: 'Leicester',
      email_address: prison_email_address,
      estate: create(:estate, nomis_id: 'LEI')
    )
  end
  let(:prisoner_number) { 'A1484AE' }
  let(:prisoner_dob) { '11-11-1971' }
  let(:visitor) { vst.visitors.first }

  around do |ex|
    travel_to(Date.new(2017, 6, 12)) { ex.run }
  end

  before do
    vst.update!(slot_option_0: '2017-06-27T14:00/16:00')
  end

  context 'with book to nomis enabled' do
    before do
      switch_on :nomis_staff_prisoner_check_enabled
      switch_on :nomis_staff_prisoner_availability_enabled

      switch_on :nomis_staff_book_to_nomis_enabled
      switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [prison.name])

      switch_on :nomis_staff_slot_availability_enabled
      switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison.name])

      switch_on :nomis_staff_offender_restrictions_enabled
      switch_on :nomis_iep_level_enabled
      switch_on :nomis_sentence_status_enabled
    end

    scenario 'accepting a booking', vcr: { cassette_name: 'book_to_nomis' } do
      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('h1', text: 'Check visit request')

      expect(page).to have_css('.notice', text: 'The prisoner date of birth, prisoner number and prison name have been verified.')
      expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')
      expect(page).to have_css('.bold-small', text: 'LEI-H-1-003')
      expect(page).to have_css('.bold-small', text: 'Standard')
      expect(page).to have_css('.bold-small', text: 'Unknown Sentenced')

      choose_date

      fill_in 'Reference number',   with: '11223344'

      fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

      within "#visitor_#{visitor.id}" do
        select 'IRMA ITSU - 03/04/1975', from: "Match to prisoner's contact list"
      end

      expect(page).to have_unchecked_field("Don't automatically copy this visit to NOMIS", visible: false)

      click_button 'Process'

      expect(page).to have_css('.notification', text: 'Thank you for processing the visit')

      vst.reload
      expect(vst).to be_booked
      expect(vst.nomis_id).to eq(5493)
      expect(vst.reference_no).to eq('11223344')
    end

    scenario 'opting out of booking to nomis', vcr: { cassette_name: 'process_happy_path_with_contact_list' } do
      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('h1', text: 'Check visit request')

      expect(page).to have_css('.notice', text: 'The prisoner date of birth, prisoner number and prison name have been verified.')
      expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')

      choose_date

      fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

      within "#visitor_#{visitor.id}" do
        select 'IRMA ITSU - 03/04/1975', from: "Match to prisoner's contact list"
      end

      check "Don't automatically copy this visit to NOMIS", visible: false

      fill_in 'Reference number',   with: '12345678'

      click_button 'Process'

      expect(page).to have_css('.notification', text: 'Thank you for processing the visit')

      vst.reload
      expect(vst).to be_booked
      expect(vst.nomis_id).to be_nil
    end

    scenario 'available date the prisoner has a closed restriction', vcr: { cassette_name: 'closed_restriction' } do
      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('.choose-date .tag--error', text: 'Closed visit restriction')

      choose_date

      within "#visitor_#{visitor.id}" do
        select 'IRMA ITSU - 03/04/1975', from: "Match to prisoner's contact list"
      end

      expect(page).to have_css('.panel', text: "This is a closed visit. Book this visit into NOMIS, then enter the reference number")

      click_button 'Process'
      expect(page).to have_css('.notification', text: 'Thank you for processing the visit')

      vst.reload
      expect(vst).to be_booked
      expect(vst.nomis_id).to be_nil
    end
  end

  context 'when book to nomis is not enabled' do
    before do
      switch_off :nomis_staff_book_to_nomis_enabled

      switch_on :nomis_staff_prisoner_check_enabled
      switch_on :nomis_staff_prisoner_availability_enabled
    end

    scenario 'accepting a booking', vcr: { cassette_name: 'process_happy_path_with_contact_list' } do
      # Create the visit before we go to the inbox
      vst

      visit prison_inbox_path
      # The most recent requested visit
      all('tr:not(.hidden-row)').last.click_link('View')

      expect(page).to have_css('form h1', text: 'Check visit request')
      expect(page).to have_css('form .bold-small', text: "The prisoner date of birth, prisoner number and prison name have been verified.")
      expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')

      choose_date

      fill_in 'Reference number',   with: '12345678'
      fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

      click_button 'Process'

      within "#visitor_#{visitor.id}" do
        expect(page).to have_css('.error-message', text: "Process this visitor to continue")
        select 'IRMA ITSU - 03/04/1975', from: "Match to prisoner's contact list"
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
      expect(visitor.nomis_id).to eq(13_428)
      expect(vst.reference_no).to eq('12345678')

      expect(contact_email_address).
      to receive_email.
      with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
      and_body(/Your visit to Leicester is now successfully confirmed/)
    end

    scenario 'accepting a booking but contact list fails', vcr: { cassette_name: 'process_contact_list_fails' } do
      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('form .notice', text: "We can’t show the NOMIS contact list right now. Please check all visitors in NOMIS")
    end
  end
end
