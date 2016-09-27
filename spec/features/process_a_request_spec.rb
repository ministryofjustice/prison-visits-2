# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  let(:contact_email_address) { 'visitor@test.example.com' }
  let(:prison_email_address) { 'prison@test.example.com' }
  let(:prison) {
    create(
      :prison,
      name: 'Reading Gaol',
      email_address: prison_email_address
    )
  }
  let(:vst) {
    create(
      :visit,
      prison: prison,
      contact_email_address: contact_email_address,
      prisoner: create(
        :prisoner,
        first_name: 'Oscar',
        last_name: 'Wilde'
      )
    )
  }

  before do
    visit prison_visit_process_path(vst, locale: 'en')
  end

  context 'with a withdrawn visit' do
    let(:vst) { create(:withdrawn_visit) }

    scenario 'is not allowed' do
      expect(page).to have_text('The visitor has withdrawn this request')
      expect(page).not_to have_text('Process')
    end
  end

  context 'with a cancelled visit' do
    let(:vst) { create(:cancelled_visit) }

    scenario 'is not allowed' do
      expect(page).to have_text("Visit can't be processed")
      expect(page).not_to have_text('Process')
    end
  end

  context 'with a booked visit' do
    let(:vst) { create(:booked_visit) }

    scenario 'is not allowed' do
      expect(page).to have_text('This request has been accepted')
      expect(page).not_to have_text('Process')
    end
  end

  context 'with a rejected visit' do
    let(:vst) { create(:rejected_visit) }

    scenario 'is not allowed' do
      expect(page).to have_text('This request has been rejected')
      expect(page).not_to have_text('Process')
    end
  end

  context 'accepting' do
    scenario 'accepting a booking' do
      find('#booking_response_selection_slot_0').click
      fill_in 'Reference number', with: '12345678'

      click_button 'Process'

      expect(page).to have_text('a confirmation email has been sent to the visitor')

      vst.reload
      expect(vst).to be_booked
      expect(vst.reference_no).to eq('12345678')

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
        and_body(/Your visit to Reading Gaol is now successfully confirmed/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking confirmation for Oscar Wilde/).
        with_body(/This is a copy of the booking confirmation email sent to the visitor/).
        with_body(/#{vst.visitors.first.full_name}/).
        with_body(/#{vst.prisoner.full_name}/)
    end

    context 'disallowed visitors' do
      before do
        vst.visitors << build(:visitor)
      end

      scenario 'accepting a booking while banning a visitor' do
        find('#booking_response_selection_slot_0').click
        fill_in 'Reference number', with: '12345678'

        within '#visitor-0' do
          check 'Visitor is banned'
        end

        click_button 'Process'

        expect(page).to have_text('a confirmation email has been sent to the visitor')

        vst.reload
        expect(vst).to be_booked
        expect(vst.reference_no).to eq('12345678')

        expect(contact_email_address).
          to receive_email.
          with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
          and_body(/cannot attend as they are currently banned/)
        expect(prison_email_address).
          to receive_email.
          with_subject(/COPY of booking confirmation for Oscar Wilde/).
          and_body(/This is a copy of the booking confirmation email sent to the visitor/)
      end

      scenario 'accepting a booking while indicating a visitor is not on the list' do
        find('#booking_response_selection_slot_0').click
        fill_in 'Reference number', with: '12345678'

        within '#visitor-0' do
          check 'Visitor is not on the contact list'
        end

        click_button 'Process'

        expect(page).to have_text('a confirmation email has been sent to the visitor')

        vst.reload
        expect(vst).to be_booked
        expect(vst.reference_no).to eq('12345678')

        expect(contact_email_address).
          to receive_email.
          with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
          and_body(/cannot attend as they are not on the prisoner’s contact list/)
        expect(prison_email_address).
          to receive_email.
          with_subject(/COPY of booking confirmation for Oscar Wilde/).
          and_body(/This is a copy of the booking confirmation email sent to the visitor/)
      end
    end

    scenario 'rejecting a booking with no available slot' do
      choose 'None of the chosen times are available'

      click_button 'Process'

      expect(page).to have_text('a rejection email has been sent to the visitor')

      vst.reload
      expect(vst).to be_rejected
      expect(vst.rejection_reason).to eq('slot_unavailable')

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
        and_body(/none of the dates and times/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
    end

    scenario 'rejecting a booking when the prisoner has no visiting allowance' do
      allowance_renewal           = 2.days.from_now.to_date
      privilege_allowance_renewal = 3.days.from_now.to_date

      choose 'Prisoner does not have any visiting allowance'
      check 'Visiting allowance (weekends and weekday visits) (VO) will be renewed:'

      fill_in 'Day',   with: allowance_renewal.day
      fill_in 'Month', with: allowance_renewal.month
      fill_in 'Year',  with: allowance_renewal.year

      check 'If weekday visit (PVO) is possible instead, choose the date PVO expires:'

      fill_in 'booking_response[privileged_allowance_expires_on][day]',   with: privilege_allowance_renewal.day
      fill_in 'booking_response[privileged_allowance_expires_on][month]', with: privilege_allowance_renewal.month
      fill_in 'booking_response[privileged_allowance_expires_on][year]',  with: privilege_allowance_renewal.year

      click_button 'Process'

      expect(page).to have_text('a rejection email has been sent to the visitor')

      vst.reload
      expect(vst).to be_rejected
      expect(vst.rejection_reason).to eq('no_allowance')
      expect(vst.rejection.allowance_renews_on).to eq(allowance_renewal)
      expect(vst.rejection.privileged_allowance_expires_on).to eq(privilege_allowance_renewal)

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
        and_body(/not got any visiting allowance/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
    end

    scenario 'rejecting a booking with incorrect prisoner details' do
      choose 'Prisoner details are incorrect'

      click_button 'Process'

      expect(page).to have_text('a rejection email has been sent to the visitor')

      vst.reload
      expect(vst.rejection_reason).to eq('prisoner_details_incorrect')
      expect(vst).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
        and_body(/correct information for the prisoner/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
    end

    scenario 'rejecting a booking when the prisoner has moved' do
      choose 'Prisoner has moved prisons'

      click_button 'Process'

      expect(page).to have_text('a rejection email has been sent to the visitor')

      vst.reload
      expect(vst.rejection_reason).to eq('prisoner_moved')
      expect(vst).to be_rejected

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
        and_body(/has moved prison/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
    end

    scenario 'rejecting a booking when no visitors are on the contact list' do
      vst.visitors.each_with_index do |_, i|
        within "#visitor-#{i}" do
          check 'Visitor is not on the contact list'
        end
      end

      click_button 'Process'

      expect(page).to have_text('a rejection email has been sent to the visitor')

      vst.reload
      expect(vst.rejection_reason).to eq('visitor_not_on_list')
      expect(vst).to be_rejected
      expect(vst.visitors.first).to be_not_on_list

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
        and_body(/prisoner’s contact list/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
    end

    scenario 'rejecting a booking when all visitors are banned' do
      vst.visitors.each_with_index do |_, i|
        within "#visitor-#{i}" do
          check 'Visitor is banned'
        end
      end

      click_button 'Process'

      expect(page).to have_text('a rejection email has been sent to the visitor')

      vst.reload
      expect(vst.rejection_reason).to eq('visitor_banned')
      expect(vst).to be_rejected
      expect(vst.visitors.first).to be_banned

      expect(contact_email_address).
        to receive_email.
        with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
        and_body(/banned from visiting/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
    end
  end
end
