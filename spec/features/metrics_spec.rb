require 'rails_helper'
require_relative '../metrics/shared_examples_for_metrics'

RSpec.feature 'Metrics', js: true do
  include ActiveJobHelper

  context 'overdue' do
    include_examples 'create visits with dates'

    before do
      luna_visit
      luna_visit
      mars_visit

      # Shared examples are booked within the first week of February, 2106. The
      # controller tracks one week behind the current date.
      travel_to Time.zone.local(2016, 2, 13) do
        visit(metrics_path(locale: 'en'))
      end
    end

    it 'has the correct overdue values' do
      expect(page).to have_selector('.luna-overdue', text: 2)
      expect(page).to have_selector('.mars-overdue', text: 1)
    end
  end

  context 'rejections' do
    include_examples 'create rejections with dates'

    before do
      luna_visits_with_dates

      # Shared examples are booked within the first week of February, 2106. The
      # controller tracks one week behind the current date.
      travel_to Time.zone.local(2016, 2, 8) do
        visit(metrics_path(locale: 'en'))
      end
    end

    it 'has the correct rejection percentages' do
      # These will track the spec in spec/metrics/rejections_spec.rb
      expect(page).to have_selector('.luna-total-rejected', text: 40.00)
      expect(page).to have_selector('.luna-no-allowance', text: 20.00)
      expect(page).to have_selector('.luna-visitor-banned', text: 10.00)
      expect(page).to have_selector('.luna-slot-unavailable', text: 10.00)
    end
  end

  context 'end to end' do
    include_examples 'create visits with dates'

    # Not using the shared examples as they seem to be memoizing again–the
    # processing state does not change as it should using the methods. Will
    # investigate later.
    let(:luna_v) {
      create(:visit, created_at: Time.zone.local(2016, 2, 1), prison: luna)
    }

    before do
      travel_to Time.zone.local(2016, 2, 2) do
        luna_v.accept!
      end

      # Shared examples are booked within the first week of February, 2106. The
      # controller tracks one week behind the current date.
      travel_to Time.zone.local(2016, 2, 13) do
        visit(metrics_path(locale: 'en'))
      end
    end

    it 'has the correct overdue values' do
      expect(page).to have_selector('.luna-ninety-fifth', text: 1.00)
      expect(page).to have_selector('.luna-median', text: 1.00)
    end
  end

  context 'end to end' do
    include_examples 'create visits with dates'

    # Not using the shared examples as they seem to be memoizing again–the
    # processing state does not change as it should using the methods. Will
    # investigate later.
    let(:luna_v) {
      create(:visit, created_at: Time.zone.local(2016, 2, 1), prison: luna)
    }

    before do
      travel_to Time.zone.local(2016, 2, 2) do
        luna_v.accept!
      end

      # Shared examples are booked within the first week of February, 2106. The
      # controller tracks one week behind the current date.
      travel_to Time.zone.local(2016, 2, 13) do
        visit(metrics_path(locale: 'en'))
      end
    end

    it 'has the correct overdue values' do
      expect(page).to have_selector('.luna-ninety-fifth', text: 1.00)
      expect(page).to have_selector('.luna-median', text: 1.00)
    end
  end
end
