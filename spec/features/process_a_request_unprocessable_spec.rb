require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  include_context 'process request setup'

  context 'not booking to nomis' do
    before do
      switch_feature_flag_with(:staff_prisons_without_nomis_contact_list, [])
    end
    around do |ex|
      travel_to(Date.new(2016, 12, 1)) { ex.run }
    end

    scenario 'trying to double process a visit', vcr: { cassette_name: 'process_booking_happy_path' } do
      # VCR doesn't allow nesting the same cassette. Since we have to requests
      # to the process page we need to setup another happy path cassette.
      Capybara.using_session('window1') do
        visit prison_visit_path(vst, locale: 'en')

        check 'Prisoner details are incorrect', visible: false
      end

      Capybara.using_session('window2') do
        visit prison_visit_path(vst, locale: 'en')

        check 'Prisoner details are incorrect', visible: false
      end

      Capybara.using_session('window1') do
        click_button 'Process'

        expect(page).to have_text('Thank you for processing the visit')
      end

      Capybara.using_session('window2') do
        click_button 'Process'

        expect(page).to have_text("Visit can't be processed")
      end
    end
  end

  context 'with book to nomis', vcr: { cassette_name: 'book_to_nomis_duplicate' } do
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
      travel_to(Date.new(2017, 06, 12)) { ex.run }
    end

    before do
      switch_on :nomis_staff_prisoner_availability_enabled
      switch_on :nomis_staff_prisoner_check_enabled
      switch_feature_flag_with(:staff_prisons_without_nomis_contact_list, [])

      switch_on :nomis_staff_book_to_nomis_enabled
      switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [vst.prison_name])

      switch_on :nomis_staff_slot_availability_enabled
      switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison.name])

      switch_on :nomis_staff_offender_restrictions_enabled

      vst.update!(slot_option_0: '2017-06-20T10:00/11:00')
    end

    scenario 'trying to double book it in nomis' do
      visit prison_visit_path(vst, locale: 'en')

      choose_date
      within "#visitor_#{visitor.id}" do
        select 'ITSU, IRMA - 03/04/1975', from: "Match to prisoner's contact list"
      end

      click_button 'Process'

      expect(page).to have_css('.error-summary', text: "Please find the visit in NOMIS and make sure these visit details match before processing.")

      choose_date

      within "#visitor_#{visitor.id}" do
        select 'ITSU, IRMA - 03/04/1975', from: "Match to prisoner's contact list"
      end

      expect(page).to have_css('#nomis-opt-out', text: "This visit won't be booked to NOMIS as it already exists")

      click_button 'Process'

      expect(page).to have_css('.notification', text: "Thank you for processing the visit")
    end
  end
end
