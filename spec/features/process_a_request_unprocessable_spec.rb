require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request', :js, :expect_exception do
  include ActiveJobHelper

  include_context 'with a process request setup'

  context 'when processing a request' do
    around do |ex|
      travel_to(Date.new(2019, 11, 13)) { ex.run }
    end

    scenario 'trying to double process a visit', vcr: { cassette_name: 'process_booking_happy_path_double_process_visit' } do
      # VCR doesn't allow nesting the same cassette. Since we have to requests
      # to the process page we need to setup another happy path cassette.
      Capybara.using_session('window1') do
        visit prison_visit_path(vst, locale: 'en')

        check 'Prisoner details are incorrect', visible: false
      end

      Capybara.using_session('window2') do
        visit prison_visit_path(vst, locale: 'en')

        check 'Prisoner details are incorrect', visible: false
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
