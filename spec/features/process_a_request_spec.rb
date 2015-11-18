require 'rails_helper'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  let(:vst) { create(:visit) }

  before do
    visit edit_prison_visit_path(vst)
  end

  scenario 'accepting a booking' do
    find('#booking_response_selection_slot_0').click
    fill_in 'Reference number', with: '12345678'

    click_button 'Send email'

    vst.reload
    expect(vst).to be_booked
    expect(vst.reference_no).to eq('12345678')
  end

  scenario 'rejecting a booking with no available slot' do
    choose 'None of the chosen times are available'

    click_button 'Send email'

    vst.reload
    expect(vst).to be_rejected
    expect(vst.rejection_reason).to eq('slot_unavailable')
  end

  scenario 'rejecting a booking when the prisoner has no visiting allowance' do
    choose 'The prisoner does not have any visiting allowance (VO)'
    check 'Visiting allowance (weekends and weekday visits) (VO) will be renewed:'
    first('input[name="booking_response[vo_renewed_on]"]').click
    check 'If weekday visit (PVO) is possible instead, choose the date PVO expires:'
    first('input[name="booking_response[pvo_expires_on]"]').click

    click_button 'Send email'

    vst.reload
    expect(vst).to be_rejected
    expect(vst.rejection_reason).to eq('no_allowance')
    expect(vst.rejection.vo_renewed_on).to eq(Time.zone.today + 1)
    expect(vst.rejection.vo_renewed_on).to eq(Time.zone.today + 1)
  end

  scenario 'rejecting a booking with incorrect prisoner details' do
    choose 'Prisoner details are incorrect'

    click_button 'Send email'

    vst.reload
    expect(vst.rejection_reason).to eq('prisoner_details_incorrect')
    expect(vst).to be_rejected
  end

  scenario 'rejecting a booking when the prisoner has moved' do
    choose 'Prisoner no longer at the prison'

    click_button 'Send email'

    vst.reload
    expect(vst.rejection_reason).to eq('prisoner_moved')
    expect(vst).to be_rejected
  end
end
