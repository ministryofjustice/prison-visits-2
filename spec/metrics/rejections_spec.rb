# frozen_string_literal: true
require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Rejections do
  context 'that are not organised by date' do
    include_examples 'create rejections without dates'

    before do
      luna_visits_without_dates
    end

    it { expect(Visit.count).to eq(10) }
    it { expect(Visit.where(processing_state: 'booked').count).to eq(6) }
    it { expect(Visit.where(processing_state: 'rejected').count).to eq(4) }

    describe Rejections::RejectionPercentageByPrison do
      before do
        mars_visits_without_dates
      end

      it 'calculates percentages of all rejections by prison' do
        expect(described_class.fetch_and_format).to be ==
                                                    { 'Lunar Penal Colony' =>
                                                      {
                                                        'no_allowance' => 20.0,
                                                        'slot_unavailable' => 10.0,
                                                        'visitor_banned' => 10.0,
                                                        'total' => 40.0
                                                      },
                                                      'Martian Penal Colony' =>
                                                      {
                                                        'no_allowance' => 20.0,
                                                        'slot_unavailable' => 10.0,
                                                        'visitor_banned' => 10.0,
                                                        'total' => 40.0
                                                      } }
      end
    end
  end

  context 'that are organized by date' do
    include_examples 'create rejections with dates'

    describe Rejections::RejectionPercentageByPrisonAndCalendarWeek do
      before do
        luna_visits_with_dates
      end

      it { expect(Visit.count).to eq(10) }
      it { expect(Visit.where(processing_state: 'booked').count).to eq(5) }
      it { expect(Visit.where(processing_state: 'rejected').count).to eq(5) }

      it 'counts visits and groups by prison, year, calendar week and visit state' do
        expect(described_class.fetch_and_format).to be ==
                                                    { 'Lunar Penal Colony' =>
                                                      {
                                                        2016 =>
                                                        { 5 =>
                                                          {
                                                            'no_allowance' => 20.00,
                                                            'slot_unavailable' => 10.00,
                                                            'visitor_banned' => 10.00,
                                                            'no_adult' => 10.00,
                                                            'total' => 50.00
                                                          } }
                                                      } }
      end

      context 'when there are visits outside of the date range' do
        before do
          travel_to(Time.zone.local(2016, 4, 1)) do
            create_list(:visit, 10, prison: luna)
          end
        end

        it 'the count is not changed for the target week' do
          expect(described_class.fetch_and_format).to be ==
                                                      { 'Lunar Penal Colony' =>
                                                        {
                                                          2016 =>
                                                          { 5 =>
                                                            {
                                                              'no_allowance' => 20.00,
                                                              'slot_unavailable' => 10.00,
                                                              'visitor_banned' => 10.00,
                                                              'no_adult' => 10.00,
                                                              'total' => 50.00
                                                            } }
                                                        } }
        end
      end
    end
  end
end
