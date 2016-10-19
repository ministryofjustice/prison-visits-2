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

  describe 'unprocessable visit request' do
    before do
      allow(Nomis::Api.instance).to receive(:lookup_active_offender).and_return(double(Nomis::Offender))
      visit prison_visit_process_path(vst, locale: 'en')
    end

    context 'with a withdrawn visit' do
      let(:vst) { create(:withdrawn_visit) }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_text('Process')
      end
    end

    context 'with a cancelled visit' do
      let(:vst) { create(:cancellation).visit }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_text('Process')
      end
    end

    context 'with a booked visit' do
      let(:vst) { create(:booked_visit) }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_text('Process')
      end
    end

    context 'with a rejected visit' do
      let(:vst) { create(:rejected_visit) }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_text('Process')
      end
    end
  end

  context "validating prisonner informations" do
    context "when the NOMIS API is working" do
      context "and the prisonner's informations are not valid" do
        it 'informs staff informations are invalid' do
          expect(Nomis::Api.instance).to receive(:lookup_active_offender).and_return(nil)
          visit prison_visit_process_path(vst, locale: 'en')

          expect(page).to have_content("The provided prisoner information didn't match any prisoner.")
        end
      end
    end

    context "when the NOMIS API is not available" do
      # Uncomment once the automatic checking NOMIS API is live.
      xit 'informs staff informations are invalid' do
        expect(Nomis::Api.instance).to receive(:lookup_active_offender).and_raise(Excon::Errors::Error)
        visit prison_visit_process_path(vst, locale: 'en')
        expect(page).to have_content("Prisoner validation service is unavailable, please manually check prisoner's informations")
      end
    end
  end

  context 'accepting' do
    before do
      allow(Nomis::Api.instance).to receive(:lookup_active_offender).and_return(double(Nomis::Offender))
      visit prison_visit_process_path(vst, locale: 'en')
    end

    scenario 'accepting a booking' do
      click_button 'Process'

      # Renders the form again
      expect(page).to have_text('Visit details')

      find('label[for=booking_response_selection_slot_0]').click

      fill_in 'Reference number', with: '12345678'

      preview_window = window_opened_by {
        click_link 'Preview Email'
      }

      within_window preview_window do
        expect(page).to have_css('p', text: /Dear #{vst.visitor_full_name}/)
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
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking confirmation for Oscar Wilde/).
        with_body(/This is a copy of the booking confirmation email sent to the visitor/).
        with_body(/#{vst.visitors.first.full_name}/).
        with_body(/#{vst.prisoner.full_name}/)
    end

    context 'disallowed visitors' do
      let(:visitor) { FactoryGirl.create(:visitor, visit: vst) }

      before do
        visitor.save!
        visit prison_visit_process_path(vst, locale: 'en')
      end

      scenario 'accepting a booking while banning a visitor' do
        find('label[for=booking_response_selection_slot_0]').click
        fill_in 'Reference number', with: '12345678'

        within "#visitor_#{visitor.id}" do
          check 'Visitor is banned'
        end

        click_button 'Process'

        expect(page).to have_text('Thank you for processing the visit')

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
        find('label[for=booking_response_selection_slot_0]').click
        fill_in 'Reference number', with: '12345678'

        within "#visitor_#{visitor.id}" do
          check 'Visitor is not on the contact list'
        end

        click_button 'Process'

        expect(page).to have_text('Thank you for processing the visit')

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

      expect(page).to have_text('Thank you for processing the visit')

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

      expect(page).to have_text('Thank you for processing the visit')

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

      expect(page).to have_text('Thank you for processing the visit')

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

      expect(page).to have_text('Thank you for processing the visit')

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
      vst.visitors.each do |v|
        within "#visitor_#{v.id}" do
          check 'Visitor is not on the contact list'
        end
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

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
      vst.visitors.each do |visitor|
        within "#visitor_#{visitor.id}" do
          check 'Visitor is banned'
        end
      end

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

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
