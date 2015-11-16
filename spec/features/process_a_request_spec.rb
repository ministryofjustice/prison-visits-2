require 'rails_helper'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  let(:vst) { create(:visit) }

  before do
    visit edit_prison_visit_path(vst)
  end

  scenario 'accepting the booking' do
    find('#booking_response_selection_slot_0').click
    fill_in 'Reference number', with: '12345678'

    click_button 'Send email'

    vst.reload

    expect(vst).to be_booked
  end

  scenario 'rejecting the booking with no available slot' do
    choose('None of the chosen times are available')
    click_button 'Send email'

    vst.reload

    expect(vst).to be_rejected
  end
end
