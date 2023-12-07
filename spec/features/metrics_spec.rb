require 'rails_helper'
require_relative '../metrics/shared_examples_for_metrics'

RSpec.feature 'Metrics', js: true do
  include ActiveJobHelper
  let(:email_address) { 'joe@example.com' }

  before do
    prison_login [Struct.new(:nomis_id).new('WED')], email_address, [SignonIdentity::ADMIN_ROLE]
  end

  context 'when overdue' do
    let(:date_today) { Time.zone.local(2016, 2, 8) }
    let!(:visits) do
      book_a_luna_visit_late
      reject_a_luna_visit_late
      book_a_mars_visit_late
      luna_visit
    end

    before do
      visit(metrics_path(locale: 'en', range: 'all_time'))
    end

    include_examples 'when creating visits with dates'
    # Shared examples are booked within the first week of February, 2106. The
    # controller tracks one week behind the current date.

    it 'has the correct overdue and waiting values' do
      expect(page).to have_selector('.luna-overdue', text: 2)
      expect(page).to have_selector('.mars-overdue', text: 1)
      expect(page).to have_selector('.luna-waiting', text: 1)
    end
  end

  context 'with rejections' do
    include_examples 'when creating rejections with dates'

    context 'when all the time' do
      before do
        stub_auth_token
        stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/staff/485926/emails")
          .to_return(body: [email_address].to_json)

        luna_visits_with_dates

        visit(metrics_path(locale: 'en', range: 'all_time'))
      end

      it 'has the correct rejection percentages' do
        # These will track the spec in spec/metrics/rejections_spec.rb
        expect(page).to have_selector('.luna-total', text: 10)
      end
    end
  end
end
