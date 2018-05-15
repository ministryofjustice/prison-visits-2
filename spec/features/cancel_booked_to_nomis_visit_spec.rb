require 'rails_helper'
require 'shared_process_setup_context'
RSpec.shared_examples_for 'does not cancel the booking in nomis' do
  it 'cancels the booking' do
    switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [])

    process_booking do
      click_on 'Processed visits'
      expect(page).to have_link('View')
      click_on 'View'
      click_button 'Cancel visit'
    end

    expect(page).not_to have_css('.panel.panel-border-narrow', text: 'This booking will automatically be cancelled in NOMIS')
    check 'Prisoner has been released'
    VCR.use_cassette('book_to_nomis') do click_button 'Cancel visit' end
    expect(page).to have_content 'The visit has been cancelled'
  end
end

RSpec.feature 'Cancel a visit booked to NOMIS', js: true do
  include_context 'with a process request setup'

  def process_booking
    VCR.use_cassette 'book_to_nomis', allow_playback_repeats: true do
      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('h1', text: 'Check visit request')
      choose_date

      within "#visitor_#{visitor.id}" do
        select 'BOB LIPMAN - 01/01/1970', from: "Match to prisoner's contact list", visible: false
      end

      click_button 'Process'

      expect(page).to have_css('.notification', text: 'Thank you for processing the visit')
      yield if block_given?
    end
  end

  let(:prison) do
    create(:prison,
      name: 'Leeds',
      email_address: prison_email_address,
      estate: create(:estate, nomis_id: 'LEI'))
  end
  let(:prisoner_number) { 'A1475AE' }
  let(:prisoner_dob)    { '23-04-1979' }
  let(:visitor)         { vst.visitors.first }

  around do |ex|
    travel_to(Date.new(2018, 4, 5)) { ex.run }
  end

  before do
    vst.update!(slot_option_0: '2018-04-08T09:00/10:00')

    allow(GATracker).
      to receive(:new).and_return(
        double(GATracker,
          send_processing_timing: nil,
          send_unexpected_rejection_event: nil,
          send_rejection_event: nil,
          send_booked_visit_event: nil,
          set_visit_processing_time_cookie: nil,
          send_cancelled_visit_event: nil))
  end

  context 'with book to nomis enabled' do
    before do
      switch_on :nomis_staff_slot_availability_enabled
      switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison.name])

      switch_on :nomis_staff_book_to_nomis_enabled

      switch_on :nomis_staff_offender_restrictions_enabled
    end

    scenario 'cancelling a booking' do
      switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [prison.name])

      process_booking do
        click_on 'Processed visits'
        expect(page).to have_link('View')
        click_on 'View'
        click_button 'Cancel visit'
      end

      VCR.use_cassette 'cancel_to_nomis' do
        check 'Prisoner has been released'
        click_button 'Cancel visit'
      end

      expect(page).to have_content 'The visit has been cancelled'
      vst.reload
      expect(
        a_request(:patch, "#{Rails.configuration.nomis_api_host}/nomisapi/offenders/1057027/visits/booking/#{vst.nomis_id}/cancel").
          with(body: { comment: nil, cancellation_code: "ADMIN" }.to_json)).to have_been_made.once
    end

    scenario "Staff can opt-out of cancelling to booking to NOMIS" do
      switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [prison.name])

      process_booking do
        click_on 'Processed visits'
        expect(page).to have_link('View')
        click_on 'View'
        click_button 'Cancel visit'
      end

      VCR.use_cassette 'cancel_to_nomis' do
        check 'Prisoner has been released'
        check "Don't automatically copy this cancellation to NOMIS"
        click_button 'Cancel visit'
      end

      vst.reload
      expect(
        a_request(:patch, "#{Rails.configuration.nomis_api_host}/nomisapi/offenders/1057027/visits/booking/#{vst.nomis_id}/cancel").
          with(body: { comment: nil, cancellation_code: "ADMIN" }.to_json)).not_to have_been_made.once
    end

    context "when the prison has not yet been activated" do
      include_examples 'does not cancel the booking in nomis'
    end
  end
end
