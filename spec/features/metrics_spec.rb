require 'rails_helper'
require_relative '../metrics/shared_examples_for_metrics'

RSpec.feature 'Metrics', js: true do
  include ActiveJobHelper
  include_examples 'create visits with dates'

  before do
    book_a_luna_visit_late
    book_a_luna_visit_late
    book_a_mars_visit_late

    # Shared examples are booked within the first week of February, 2106. The
    # controller tracks one week behind the current date.
    travel_to Time.zone.local(2016, 2, 13) do
      visit(metrics_path(locale: 'en'))
    end
  end

  it 'should not fail' do
    expect(page).to have_selector('.luna-overdue', text: 2)
    expect(page).to have_selector('.mars-overdue', text: 1)
  end
end
