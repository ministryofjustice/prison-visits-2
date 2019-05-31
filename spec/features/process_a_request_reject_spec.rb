require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request', :expect_exception, :js do
  include ActiveJobHelper

  include_context 'with a process request setup'

  let(:stubbed_date) { Date.new(2018, 4, 5) }

  around do |ex|
    # Prisoner availability is date dependent both on the responses from Nomis
    # and in the Nomis client logic as it validates the start / end date
    # parameters before making the call.
    travel_to(stubbed_date) { ex.run }
  end

  def check_nomis_override_message_does_not_trigger
    expect(page).to have_css('.error-summary', text: 'Please either reject or accept the booking')
    uncheck 'Prisoner details are incorrect', visible: false
    expect(page).not_to have_css('#js-OverrideMessage')
  end

  describe 'when the prisoner is not registered at the prison', vcr: { cassette_name: 'prisoner_not_at_given_prison' } do
    let(:prisoner_number) { 'A1410AE' }

    before do
      visit prison_visit_path(vst, locale: 'en')
    end

    scenario 'rejecting a booking with incorrect prisoner details' do
      expect(page.find('input[type="checkbox"][id="prisoner_details_incorrect"]', visible: false)).to be_checked
    end
  end

  describe 'rejecting', vcr: { cassette_name: 'process_booking_happy_path_reject' } do
    before do
      visit prison_visit_path(vst, locale: 'en')
    end

    scenario 'rejecting a booking with no available slot' do
      choose 'None of the chosen times are available', visible: false

      fill_in 'This message will be included in the email sent to the visitor', with: 'A staff message'

      preview_window = window_opened_by {
        click_link 'Preview email'
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

    scenario 'rejecting a booking with incorrect prisoner details', vcr: { cassette_name: 'process_booking_happy_path_reject', allow_playback_repeats: true }  do
      choose_date
      check 'Prisoner details are incorrect', visible: false
      click_button 'Process'

      check_nomis_override_message_does_not_trigger

      choose 'None of the chosen times are available', visible: false
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

    scenario 'rejecting a booking with multiple rejection reasons' do
      check 'Prisoner on external movement', visible: false
      check 'Duplicate visit request', visible: false

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst.rejection_reasons).
        to include('prisoner_out_of_prison', 'duplicate_visit_request')

      expect(vst).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/the prisoner has a restriction/).
        and_body(/already requested/)
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
        check 'Not on contact list', visible: false
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst).to be_rejected
      expect(vst.visitors.first).to be_not_on_list
    end

    scenario 'rejecting a booking for any reason',
             vcr: { cassette_name: 'process_booking_happy_path_reject', allow_playback_repeats: true } do
      within '.other-reason' do
        check 'Other reason', visible: false
      end

      click_button 'Process'

      within '#other_reason_detail' do
        fill_in 'Enter rejection reason', with: 'Other reason'
      end

      click_button 'Process'

      expect(vst.rejection_reasons).to include('other')
      expect(vst.reload).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/not been able to book your visit to #{prison.name}. Please do NOT go to the prison/)
    end

    scenario "lead visitor can't attend for other reasons" do
      within "#visitor_#{vst.principal_visitor.id}" do
        check 'Other reason', visible: false
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/)

      vst.reload

      expect(vst).to be_rejected
      expect(vst.visitors.first).to be_other_rejection_reason
    end
  end
end
