require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request - Acceptance', js: true do
  include ActiveJobHelper

  include_context 'process request setup'

  context 'with visitor contact list', vcr: { cassette_name: 'process_happy_path_with_contact_list' } do
    # Leicester has contact list enabled in 'test'
    let(:prison) do
      FactoryGirl.create(:prison,
        name: 'Leicester',
        email_address: prison_email_address)
    end
    let(:prisoner_number) { 'A1484AE' }
    let(:prisoner_dob) { '11-11-1971' }
    let(:visitor) { vst.visitors.first }

    around do |ex|
      travel_to(Date.new(2017, 5, 10)) { ex.run }
    end

    before do
      switch_feature_flag_with(:staff_prisons_with_nomis_contact_list, [prison.name])
    end

    scenario 'accepting a booking' do
      visit prison_visit_process_path(vst, locale: 'en')
      click_button 'Process'

      # Renders the form again
      expect(page).to have_text('Visit details')

      expect(page).to have_content("The prisoner date of birth and number have been verified.")
      expect(page).to have_css('.choose-date .tag--verified', text: 'Prisoner available')

      choose_date

      fill_in 'Reference number',   with: '12345678'
      fill_in 'Message (optional)', with: 'A staff message'

      within "#visitor_#{visitor.id}" do
        select 'IRMA ITSU - 03/04/1975', from: 'Match to contact list'
      end

      preview_window = window_opened_by {
        click_link 'Preview Email'
      }

      within_window preview_window do
        expect(page).to have_css('p', text: /Dear #{vst.visitor_full_name}/)
        expect(page).to have_css('p', text: 'A staff message')
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      visitor.reload
      expect(vst).to be_booked
      expect(visitor.nomis_id).to eq(13_428)
      expect(vst.reference_no).to eq('12345678')

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
        and_body(/Your visit to Leicester is now successfully confirmed/)

      visit prison_visit_path(vst, locale: 'en')
      expect(page).to have_css('span', text: 'by joe@example.com')
    end
  end

  context 'accepting', vcr: { cassette_name: 'process_booking_happy_path' } do
    around do |ex|
      travel_to(Date.new(2016, 12, 1)) { ex.run }
    end

    context "validating prisoner informations - sad paths" do
      context "and the prisoner's informations are not valid", vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
        let(:slot_zero) { ConcreteSlot.new(2016, 5, 1, 10, 30, 11, 30) }
        let(:slot_one) { ConcreteSlot.new(2016, 5, 21, 10, 30, 11, 30) }

        let(:prisoner_number) { 'Z9999ZZ' }

        before do
          vst.update!(
            slot_option_0: slot_zero.iso8601,
            slot_option_1: slot_one.iso8601,
            slot_option_2: nil
          )
        end

        it 'informs staff prisoner details are invalid' do
          visit prison_visit_process_path(vst, locale: 'en')
          expect(page).to have_content("The prisoner date of birth and number do not match.")
        end
      end

      context "when the NOMIS API has an error", vcr: { cassette_name: 'lookup_active_offender-error' } do
        it 'informs staff that the the check had a problem' do
          visit prison_visit_process_path(vst, locale: 'en')
          expect(page).to have_content("The check couldn't take place due to a system error, please verify manually")
        end
      end
    end

    scenario 'accepting a booking' do
      visit prison_visit_process_path(vst, locale: 'en')
      click_button 'Process'

      # Renders the form again
      expect(page).to have_text('Visit details')

      expect(page).to have_content("The prisoner date of birth and number have been verified.")
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

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst).to be_booked
      expect(vst.reference_no).to eq('12345678')

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
        and_body(/Your visit to Reading Gaol is now successfully confirmed/)

      visit prison_visit_path(vst, locale: 'en')
      expect(page).to have_css('span', text: 'by joe@example.com')
    end

    context 'disallowed visitors' do
      let(:visitor) { create(:visitor, visit: vst) }

      before do
        visitor.save!
        visit prison_visit_process_path(vst, locale: 'en')
      end

      scenario 'accepting a booking while banning a visitor' do
        choose_date

        fill_in 'Reference number', with: '12345678'

        choose_date

        fill_in 'Reference number', with: '12345678'

        within "#visitor_#{visitor.id}" do
          find('input[type="checkbox"][id*="banned"]').click
        end

        click_button 'Process'

        expect(page).to have_text('Thank you for processing the visit')

        visit prison_visit_path(vst)

        expect(page).to have_css('div.tag--heading', text: 'Booked')
        expect(page).to have_css('div.text-secondary', text: 'Ref: 12345678')

        within "#visitor_#{visitor.id}" do
          expect(page).to have_text('Banned')
        end

        expect(contact_email_address).
          to receive_email.
          with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
          and_body(/cannot attend as they are currently banned/)
      end

      scenario 'accepting a booking while indicating a visitor is not on the list' do
        visit prison_visit_process_path(vst, locale: 'en')

        choose_date
        fill_in 'Reference number', with: '12345678'
        check 'visit[visitors_attributes][1][not_on_list]'

        click_button 'Process'

        expect(page).to have_text('Thank you for processing the visit')

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
