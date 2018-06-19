require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request - Acceptance with the contact list enabled', :js, :expect_exception do
  include ActiveJobHelper

  include_context 'with a process request setup'

  let(:prison) do
    create(:prison,
      name: 'Leeds',
      email_address: prison_email_address,
      estate: create(:estate, nomis_id: 'LEI')
    )
  end
  let(:prisoner_number) { 'A1475AE' }
  let(:prisoner_dob) { '23-04-1979' }
  let(:visitor_details) { 'BOB LIPMAN - 01/01/1970' }
  let(:nomis_comments) { 'This is a comment to be added to Nomis' }
  let(:visitor) { vst.visitors.first }

  around do |ex|
    travel_to(Date.new(2018, 4, 5)) { ex.run }
  end

  before do
    vst.update!(slot_option_0: '2018-04-19T10:00/11:30')
  end

  context 'with book to nomis enabled' do
    before do
      switch_on :nomis_staff_book_to_nomis_enabled
      switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [prison.name])

      switch_on :nomis_staff_slot_availability_enabled
      switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison.name])

      switch_on :nomis_staff_restrictions_enabled
    end

    scenario 'accepting a booking', vcr: { cassette_name: 'accept_book_to_nomis_enabled' } do
      vst.update!(slot_option_0: '2018-05-24T10:00/11:30')

      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('h1', text: 'Check visit request')

      expect(page).to have_css('.notice', text: 'The prisoner date of birth, prisoner number and prison name have been verified.')
      expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')
      expect(page).to have_css('.bold-small', text: 'LEI-H-2-006')
      expect(page).to have_css('.bold-small', text: 'Standard')
      expect(page).to have_css('.bold-small', text: 'Adult Imprisonment Without Option CJA03')
      choose_date

      fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

      within "#visitor_#{visitor.id}" do
        select visitor_details, from: 'Match to prisoner\'s contact list'
      end

      choose 'Yes - copy to NOMIS'
      choose 'book_to_nomis_pvo'

      fill_in 'nomis_comments', with: nomis_comments
      click_button 'Process'

      expect(page).to have_css('.notification', text: 'Thank you for processing the visit')

      vst.reload
      expect(vst).to be_booked
      expect(vst.nomis_id).to eq(5955)
      expect(vst.nomis_comments).to eq(nomis_comments)
      expect(vst.visit_order).to have_attributes(type: 'VisitOrder', number: 2_018_000_000_130)
    end

    scenario 'opting out of booking to nomis', vcr: { cassette_name: 'opt_out_of_book_to_nomis' } do
      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('h1', text: 'Check visit request')

      expect(page).to have_css('.notice', text: 'The prisoner date of birth, prisoner number and prison name have been verified.')
      expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')

      choose_date

      fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

      within "#visitor_#{visitor.id}" do
        select visitor_details, from: "Match to prisoner's contact list"
      end

      choose "No - do not copy to NOMIS"

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
        select visitor_details, from: "Match to prisoner's contact list"
      end

      expect(page).to have_css('#nomis-opt-out', text: "This is a closed visit.\nBook this visit into NOMIS, then enter the reference number")

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
    end

    scenario 'accepting a booking', vcr: { cassette_name: 'process_happy_path_book_to_nomis_not_enabled' } do
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
      expect(visitor.nomis_id).to eq(13_621)
      expect(vst.reference_no).to eq('12345678')

      expect(contact_email_address).
      to receive_email.
      with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
      and_body(/Your visit to Leeds is now successfully confirmed/)
    end

    context 'accepting a booking but contact list fails', vcr: { cassette_name: 'process_contact_list_fails' } do
      before do
        simulate_api_error_for(:fetch_contact_list)
      end

      it 'is expected that the contact list is not available' do
        visit prison_visit_path(vst, locale: 'en')
        expect(page).to have_css('form .notice', text: "We can’t show the NOMIS contact list right now. Please check all visitors in NOMIS")
      end
    end
  end
end
