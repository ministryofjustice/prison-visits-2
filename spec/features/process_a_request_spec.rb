require 'rails_helper'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  scenario 'accepting the booking' do
    vst = create(:visit)
    visit edit_prison_visit_path(vst)

    find('#booking_response_selection_slot_0').click
    fill_in 'Reference number', with: '12345678'

    click_button 'Send email'

    vst.reload

    expect(vst).to be_booked
  end
end
