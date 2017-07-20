require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request - Acceptance without the contact list enabled', js: true do
  include ActiveJobHelper

  include_context 'process request setup'

  before do
    switch_feature_flag_with(:staff_prisons_with_nomis_contact_list, [])
  end

  context 'accepting', vcr: { cassette_name: 'process_booking_happy_path' } do
    around do |ex|
      travel_to(Date.new(2016, 12, 1)) { ex.run }
    end
    let(:prison) do
      create(:prison,
        name: 'ISIS HMP/YOI',
        estate: create(:estate, nomis_id: 'ISI')
            )
    end

    context "validating prisoner informations - sad paths" do
      before do
        switch_on :nomis_staff_prisoner_check_enabled
      end

      context "and the prisoner's informations are not valid", vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
        let(:slot_zero) { ConcreteSlot.new(2016, 5, 1, 10, 30, 11, 30) }
        let(:slot_one) { ConcreteSlot.new(2016, 5, 21, 10, 30, 11, 30) }

        let(:prisoner_number) { 'Z9999ZZ' }

        it 'informs staff prisoner details are invalid' do
          visit prison_visit_path(vst, locale: 'en')
          expect(page).to have_css('form .notice', text: "The prisoner date of birth and number do not match.")
        end
      end

      context "when the NOMIS API has an error", vcr: { cassette_name: 'lookup_active_offender-error' } do
        it 'informs staff that the the check had a problem' do
          visit prison_visit_path(vst, locale: 'en')
          expect(page).to have_css('form .notice', text: "The check couldn't take place due to a system error, please verify manually")
        end
      end
    end

    scenario 'accepting a booking' do
      switch_on :nomis_staff_prisoner_check_enabled
      switch_on :nomis_staff_prisoner_availability_enabled

      visit prison_visit_path(vst, locale: 'en')
      click_button 'Process'

      # Renders the form again
      expect(page).to have_css('form h1', text: 'Visit details')
      expect(page).to have_css('form .bold-small', text: "The prisoner date of birth, prisoner number and prison name have been verified.")
      expect(page).to have_css('.column-one-quarter:nth-child(4) .tag--booked', text: 'Verified')
      expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')

      choose_date

      fill_in 'Reference number',   with: '12345678'
      fill_in 'Message (optional)', with: 'A staff message'

      preview_window = window_opened_by {
        click_link 'Preview Email'
      }

      within_window preview_window do
        expect(page).to have_css('p', text: /Dear #{vst.visitor_full_name}/)
        expect(page).to have_css('p', text: 'A staff message')
      end

      click_button 'Process'

      expect(page).to have_css('#content .notification', text: 'Thank you for processing the visit')

      vst.reload
      expect(vst).to be_booked
      expect(vst.reference_no).to eq('12345678')

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
        and_body(/Your visit to #{prison.name} is now successfully confirmed/)

      visit prison_visit_path(vst, locale: 'en')
      expect(page).to have_css('span', text: 'by joe@example.com')
    end

    context 'disallowed visitors' do
      let(:visitor) { create(:visitor, visit: vst) }

      before do
        visitor.save!
        visit prison_visit_path(vst, locale: 'en')
      end

      scenario 'accepting a booking while banning a visitor' do
        choose_date

        fill_in 'Reference number', with: '12345678'

        choose_date

        fill_in 'Reference number', with: '12345678'

        within "#visitor_#{visitor.id}" do
          check 'Visitor is banned', visible: false
        end

        click_button 'Process'

        expect(page).to have_css('#content .notification', text: 'Thank you for processing the visit')

        visit prison_visit_path(vst, locale: 'en')

        expect(page).to have_css('div.tag--heading', text: 'Booked')
        expect(page).to have_css('div.text-secondary', text: 'Ref: 12345678')

        within "#visitor_#{visitor.id}" do
          expect(page).to have_css('.tag--error', text: 'Banned')
        end

        expect(contact_email_address).
          to receive_email.
          with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
          and_body(/cannot attend as they are currently banned/)
      end

      scenario 'accepting a booking while indicating a visitor is not on the list' do
        visit prison_visit_path(vst, locale: 'en')

        choose_date
        fill_in 'Reference number', with: '12345678'

        within "#visitor_#{visitor.id}" do
          check 'Not on contact list', visible: false
        end

        click_button 'Process'

        expect(page).to have_css('#content .notification', text: 'Thank you for processing the visit')

        vst.reload
        expect(vst).to be_booked
        expect(vst.reference_no).to eq('12345678')

        expect(contact_email_address).
          to receive_email.
          with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
          and_body(/cannot attend as they are not on the prisoner's contact list/)
      end
    end
  end
end
