require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  include_context 'with a process request setup'

  around do |ex|
    # Prisoner availability is date dependent both on the responses from Nomis
    # and in the Nomis client logic as it validates the start / end date
    # parameters before making the call.
    travel_to(Date.new(2016, 12, 1)) { ex.run }
  end

  describe 'rejecting', vcr: { cassette_name: 'process_booking_happy_path' } do
    before do
      switch_feature_flag_with(:staff_prisons_without_nomis_contact_list, [])
      visit prison_visit_path(vst, locale: 'en')
    end

    scenario 'rejecting a booking with no available slot' do
      choose 'None of the chosen times are available', visible: false

      fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

      preview_window = window_opened_by {
        click_link 'Preview Email'
      }

      within_window preview_window do
        expect(page).to have_css('p', text: /Dear #{vst.visitor_first_name}/)
        expect(page).to have_css('p', text: 'A staff message')
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst).to be_rejected
      expect(vst.rejection_reasons).to eq(['slot_unavailable'])

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/the dates and times you chose aren't available/)
    end

    scenario 'a booking when the prisoner has no visiting allowance' do
      allowance_renewal = 2.days.from_now.to_date

      check 'Prisoner does not have any visiting allowance', visible: false

      within '.issue-with-prisoner' do
        fill_in 'Day',   with: allowance_renewal.day
        fill_in 'Month', with: allowance_renewal.month
        fill_in 'Year',  with: allowance_renewal.year
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst).to be_rejected
      expect(vst.rejection_reasons).to include('no_allowance')
      expect(vst.rejection.allowance_renews_on).to eq(allowance_renewal)

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/the prisoner has used their allowance of visits for this month/)
    end

    scenario 'rejecting a booking with incorrect prisoner details' do
      check 'Prisoner details are incorrect', visible: false

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst.rejection_reasons).to include('prisoner_details_incorrect')
      expect(vst).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/we can't find the prisoner from the information you've given/)
    end

    scenario 'rejecting a booking when the prisoner has moved' do
      check 'Prisoner has moved prisons', visible: false

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst.rejection_reasons).to include('prisoner_moved')
      expect(vst).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/has moved prison/)
    end

    scenario 'rejecting a booking when the prisoner is banned and out of prison' do
      check 'Prisoner banned from receiving visits', visible: false
      check 'Prisoner on external movement', visible: false

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst.rejection_reasons).to include('prisoner_banned')
      expect(vst.rejection_reasons).to include('prisoner_out_of_prison')
      expect(vst).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/the prisoner has a restriction/)
    end

    scenario 'rejecting a booking when no visitors are on the contact list' do
      vst.visitors.each do |visitor|
        within "#visitor_#{visitor.id}" do
          check 'Not on contact list', visible: false
        end
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst.rejection.reasons).to include('visitor_not_on_list')
      expect(vst).to be_rejected
      expect(vst.visitors.first).to be_not_on_list

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/prisoner's contact list/)
    end

    scenario 'rejecting a booking when all visitors are banned' do
      vst.visitors.each do |visitor|
        within "#visitor_#{visitor.id}" do
          check 'Visitor is banned', visible: false
        end
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst.rejection_reasons).to include('visitor_banned')
      expect(vst).to be_rejected
      expect(vst.visitors.first).to be_banned

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/banned from visiting/)
    end

    scenario "rejecting a visit by indicating the lead visitor can't attend" do
      choose_date

      within "#visitor_#{vst.principal_visitor.id}" do
        check 'Not on contact list'
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst).to be_rejected
      expect(vst.visitors.first).to be_not_on_list
    end

    scenario 'rejecting a booking for any reason',
      vcr: { cassette_name: 'process_booking_happy_path', allow_playback_repeats: true } do
      check 'Other', visible: false
      click_button 'Process'

      fill_in 'Enter rejection reason', with: 'Other reason'
      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst.rejection_reasons).to include('other')
      expect(vst).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/not been able to book your visit to #{prison.name}. Please do NOT go to the prison/)
    end
  end
end
