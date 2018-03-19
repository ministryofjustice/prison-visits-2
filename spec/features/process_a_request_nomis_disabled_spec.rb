require "rails_helper"
require 'shared_process_setup_context'

RSpec.feature 'Processing a request - NOMIS API disasbled', :js do
  include ActiveJobHelper

  include_context 'with a process request setup'

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
    travel_to(Date.new(2017, 6, 12)) { ex.run }
  end

  before do
    vst.update!(slot_option_0: '2017-06-27T14:00/16:00')
  end

  context 'with all of the flags switched on' do
    before do
      switch_off_api
      switch_on :nomis_staff_prisoner_check_enabled
      switch_on :nomis_staff_prisoner_availability_enabled

      switch_on :nomis_staff_book_to_nomis_enabled
      switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [prison.name])

      switch_on :nomis_staff_slot_availability_enabled
      switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison.name])

      switch_on :nomis_staff_offender_restrictions_enabled
      switch_on :nomis_internal_location_enabled
      switch_on :nomis_iep_level_enabled
      switch_on :nomis_sentence_status_enabled
    end

    let(:ga_tracker) do
      double(
        GATracker,
        set_visit_processing_time_cookie: nil,
        send_processing_timing: nil,
        send_unexpected_rejection_event: nil,
        send_rejection_event: nil,
        send_booked_visit_event: nil
      )
    end

    it 'enables staff to process a visit' do
      allow(GATracker).
        to receive(:new).
             and_return(ga_tracker)

      visit prison_visit_path(vst, locale: 'en')

      expect(page).to have_css('h1', text: 'Check visit request')
      choose_date
      click_button 'Process'

      expect(page).to have_css('#content .notification', text: 'Thank you for processing the visit')

      vst.reload
      expect(vst).to be_booked
    end
  end
end
