# frozen_string_literal: true
require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  include_context 'process request setup'

  around do |ex|
    # Prisoner availability is date dependent both on the responses from Nomis
    # and in the Nomis client logic as it validates the start / end date
    # parameters before making the call.
    travel_to(Date.new(2016, 12, 1)) { ex.run }
  end

  describe 'rejecting', vcr: { cassette_name: 'process_booking_happy_path' } do
    before do
      visit prison_visit_process_path(vst, locale: 'en')
    end

    scenario 'rejecting a booking with no available slot' do
      choose 'None of the chosen times are available'

      fill_in 'Message (optional)', with: 'A staff message'

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

      check 'Prisoner does not have any visiting allowance'

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
      check 'Prisoner details are incorrect'

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
      check 'Prisoner has moved prisons'

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

    scenario 'rejecting a booking when no visitors are on the contact list' do
      vst.visitors.each_with_index do |_visitor, i|
        check "visit[visitors_attributes][#{i}][not_on_list]"
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
      vst.visitors.each_with_index do |_, i|
        check "visit[visitors_attributes][#{i}][banned]"
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
  end
end
