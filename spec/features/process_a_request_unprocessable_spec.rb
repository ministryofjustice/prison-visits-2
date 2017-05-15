require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  include_context 'process request setup'

  before do
    # We keep getting random /favicon.ico not found errors
    Capybara.raise_server_errors = false
  end

  describe 'unprocessable visit request' do
    before do
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

  context do
    around do |ex|
      travel_to(Date.new(2016, 12, 1)) { ex.run }
    end

    scenario 'trying to double process a visit', vcr: { cassette_name: 'process_booking_happy_path' } do
      # VCR doesn't allow nesting the same cassette. Since we have to requests
      # to the process page we need to setup another happy path cassette.
      VCR.use_cassette("process_booking_happy_path-dup") do
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
end
