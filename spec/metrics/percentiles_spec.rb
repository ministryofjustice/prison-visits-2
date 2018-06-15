require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Percentiles do
  context 'when they are not organised by date' do
    include_examples 'when creating and processing visits timed by seconds'

    describe Percentiles::Distribution do
      it 'returns the 95% 50% times' do
        expect(described_class.fetch_and_format).to be ==
          {
            95 => 55,
            50 => 5
          }
      end
    end

    describe Percentiles::DistributionByPrison do
      it 'returns the 95% 50% times' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            {
              95 => 55,
              50 => 5
            },
            'Martian Penal Colony' =>
            {
              95 => 55,
              50 => 5
            }
        }
      end
    end
  end

  context 'when they are organized by date' do
    include_examples 'when creating and processing visits with dates'

    describe Percentiles::DistributionByPrisonAndCalendarWeek do
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
                  95 => 777_600,
                  50 => 432_000
                },
                6 =>
                {
                  95 => 777_600,
                  50 => 432_000
                },
                7 => {
                  95 => 777_600,
                  50 => 432_000
                }
              }
            }
        }
      end

      context 'when they are aggregated across all prisons' do
        before do
          mars_visits_with_dates
          luna_visits_with_dates
        end

        it 'counts visits and groups by year, calendar week and visit state' do
          expect(described_class.fetch_and_format(:concatenate)).to be ==
            { 'all' =>
              {
                2016 =>
                { 5 =>
                  {
                    95 => 777_600,
                    50 => 432_000
                  },
                  6 =>
                  {
                    95 => 777_600,
                    50 => 432_000
                  },
                  7 => {
                    95 => 777_600,
                    50 => 432_000
                  }
                }
              }
          }
        end
      end

      describe Percentiles::DistributionByPrisonAndCalendarDate do
        before do
          luna_visits_with_dates
        end

        it 'calculates distribution and groups by prison, nested calendar date' do
          expect(described_class.fetch_and_format).to be ==
            { 'Lunar Penal Colony' =>
              {
                2016 =>
                { 2 =>
                  {
                    1 =>
                    {
                      95 => 777_600,
                      50 => 432_000
                    },
                    8 =>
                    {
                      95 => 777_600,
                      50 => 432_000
                    },
                    15 => {
                      95 => 777_600,
                      50 => 432_000
                    }
                  }
                }
              }
          }
        end

        context 'when they are aggregated across all prisons' do
          before do
            mars_visits_with_dates
            luna_visits_with_dates
          end

          it 'counts visits and groups by calendar date' do
            expect(described_class.fetch_and_format(:concatenate)).to be ==
              { 'all' =>
                {
                  2016 =>
                  { 2 =>
                    {
                      1 =>
                      {
                        95 => 777_600,
                        50 => 432_000
                      },
                      8 =>
                      {
                        95 => 777_600,
                        50 => 432_000
                      },
                      15 => {
                        95 => 777_600,
                        50 => 432_000
                      }
                    }
                  }
                }
            }
          end
        end
      end
    end
  end
end
