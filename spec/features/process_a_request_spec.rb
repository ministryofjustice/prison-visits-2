require 'rails_helper'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  def sanitize_to_id(value)
    value.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def choose_date
    within '.choose-date' do
      find("label[for='visit_slot_granted_#{sanitize_to_id(vst.slots.first.iso8601)}']").click
    end
  end

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
    ).decorate
  }

  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'mojsso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'email' => 'joe@example.com',
        'permissions' => [
          { 'organisation' => vst.prison.estate.sso_organisation_name, roles: [] }
        ],
        'links' => {
          'profile' => 'http://example.com/profile',
          'logout' => 'http://example.com/logout'
        }
      }
    }
  end

  before do
    OmniAuth.config.add_mock(:mojsso, sso_response)
    visit prison_inbox_path
  end

  describe 'unprocessable visit request' do
    before do
      allow(Nomis::Api.instance).to receive(:lookup_active_offender).and_return(double(Nomis::Offender))
      visit prison_visit_process_path(vst, locale: 'en')
    end

    context 'with a withdrawn visit' do
      let(:vst) { create(:withdrawn_visit) }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_button('Process')
      end
    end

    context 'with a cancelled visit' do
      let(:vst) { create(:cancellation).visit }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_button('Process')
      end
    end

    context 'with a booked visit' do
      let(:vst) { create(:booked_visit) }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_button('Process')
      end
    end

    context 'with a rejected visit' do
      let(:vst) { create(:rejected_visit) }

      scenario 'is not allowed' do
        expect(page).to have_text("Visit can't be processed")
        expect(page).not_to have_button('Process')
      end
    end
  end

  context "validating prisonner informations" do
    context "when the NOMIS API is working" do
      context "and the prisoner's informations are not valid" do
        it 'informs staff informations are invalid' do
          expect(Nomis::Api.instance).to receive(:lookup_active_offender).and_return(nil)
          visit prison_visit_process_path(vst, locale: 'en')
          expect(page).to have_content("The prisoner date of birth and number do not match.")
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
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    scenario 'accepting a booking' do
      visit prison_visit_process_path(vst, locale: 'en')
      click_button 'Process'

      # Renders the form again
      expect(page).to have_text('Visit details')

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
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking confirmation for Oscar Wilde/).
        with_body(/This is a copy of the booking confirmation email sent to the visitor/).
        with_body(/#{vst.visitors.first.full_name}/).
        with_body(/#{vst.prisoner.full_name}/)

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
        check 'visit[visitors_attributes][1][banned]'

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
        expect(prison_email_address).
          to receive_email.
          with_subject(/COPY of booking confirmation for Oscar Wilde/).
          and_body(/This is a copy of the booking confirmation email sent to the visitor/)
      end
    end
  end

  describe 'rejecting' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
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

      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/the dates and times you chose aren't available/)
    end

    scenario 'a booking when the prisoner has no visiting allowance' do
      allowance_renewal = 2.days.from_now.to_date

      check 'Prisoner does not have any visiting allowance'

      fill_in 'Day',   with: allowance_renewal.day
      fill_in 'Month', with: allowance_renewal.month
      fill_in 'Year',  with: allowance_renewal.year

      click_button 'Process'

      expect(page).to have_text('Thank you for processing the visit')

      vst.reload
      expect(vst).to be_rejected
      expect(vst.rejection_reasons).to include('no_allowance')
      expect(vst.rejection.object.allowance_renews_on).to eq(allowance_renewal)

      expect(contact_email_address).
        to receive_email.
        with_subject(/Your visit to #{prison.name} is NOT booked/).
        and_body(/the prisoner has used their allowance of visits for this month/)
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
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
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
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
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
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
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
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
      expect(prison_email_address).
        to receive_email.
        with_subject(/COPY of booking rejection for Oscar Wilde/).
        and_body(/This is a copy of the booking rejection email sent to the visitor/)
    end

    scenario 'trying to double process a visit' do
      Capybara.using_session('window1') do
        visit prison_visit_process_path(vst, locale: 'en')

        check 'Prisoner details are incorrect'
      end

      Capybara.using_session('window2') do
        visit prison_visit_process_path(vst, locale: 'en')

        check 'Prisoner details are incorrect'
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
end
