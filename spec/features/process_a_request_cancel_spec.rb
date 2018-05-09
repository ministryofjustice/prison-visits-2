require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request', :js, :expect_exception do
  include ActiveJobHelper
  include_context 'with a process request setup'
  describe 'cancelling' do
    before do
      vst.assign_attributes(slot_granted: vst.slot_option_0)
      BookingResponder.new(StaffResponse.new(visit: vst)).respond!
      visit prison_visit_path(vst, locale: 'en')
    end

    scenario 'cancelling a booked visit with more than one reason', vcr: { cassette_name: 'multiple_cancellation_reasons' } do
      check 'Visit slot no longer available'
      check 'Visitor is banned'

      click_button 'Cancel visit'

      expect(page).to have_css('.tag--heading', text: /Cancelled/)
      expect(page).to have_css('.panel', text: /None of the dates and times chosen were available/)
      expect(page).to have_css('.panel', text: /A visitor has been banned/)
    end
  end
end
