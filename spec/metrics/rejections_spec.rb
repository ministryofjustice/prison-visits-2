require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Rejections do
  context 'that are not organised by date' do
    include_examples 'create rejections without dates'

    describe Rejections::RejectionPercentage do
      it 'calculates percentages of all rejections' do
        expect(described_class.fetch_and_format).to eq('no_allowance' => 10.0,
                                                       'slot_unavailable' => 10.0,
                                                       'visitor_banned' => 10.0,
                                                       'total' => 30.0)
      end
    end

    describe Rejections::RejectionPercentageByPrison do
      it 'calculates percentages of all rejections by prison' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            {
              'no_allowance' => 10.0,
              'slot_unavailable' => 10.0,
              'visitor_banned' => 10.0,
              'total' => 30.0
            },
            'Martian Penal Colony' =>
            {
              'no_allowance' => 10.0,
              'slot_unavailable' => 10.0,
              'visitor_banned' => 10.0,
              'total' => 30.0
            }
        }
      end
    end
  end

  context 'that are organized by date' do
    include_examples 'create rejections with dates'

    describe Rejections::RejectionPercentageByPrisonAndCalendarWeek do
      before do
        luna_visits_with_dates
      end

      it 'counts visits and groups by prison, year, calendar week and visit state' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            {
              2016 =>
              { 5 =>
                {
                  'no_allowance' => 18.18,
                  'slot_unavailable' => 9.09,
                  'visitor_banned' => 9.09,
                  'total' => 36.36
                }
              }
            }
        }
      end
    end
  end
end
