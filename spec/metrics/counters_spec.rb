require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Counters do
  context 'without dates' do
    include_examples 'create visits without dates'

    describe Counters::CountVisits do
      it 'returns a total count of all visits' do
        expect(described_class.fetch_and_format).to eq(10)
      end
    end

    describe Counters::CountVisitsByState do
      it 'returns a total count of all visits' do
        expect(described_class.fetch_and_format).to eq('booked' => 2,
                                                       'cancelled' => 2,
                                                       'withdrawn' => 2,
                                                       'rejected' => 2,
                                                       'requested' => 2)
      end
    end

    describe Counters::CountVisitsByPrisonAndState do
      it 'returns counts by state that are grouped by prison' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            { 'requested' => 1,
              'booked' => 1,
              'rejected' => 1,
              'cancelled' => 1,
              'withdrawn' => 1
            },
            'Martian Penal Colony' =>
            { 'requested' => 1,
              'booked' => 1,
              'rejected' => 1,
              'cancelled' => 1,
              'withdrawn' => 1
            }
        }
      end
    end
  end

  context 'by date' do
    include_examples 'create visits with dates'

    describe Counters::CountVisitsByPrisonAndCalendarWeek do
      before do
        luna_visits_with_dates
      end

      it 'returns counts by state that are grouped by prison, year, and week' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            {
              2015 => {
                53 => {
                  'cancelled' => 1
                }
              },
              2016 => {
                5 => {
                  'requested' => 1,
                  'rejected' => 1,
                  'booked' => 1
                },
                6 => {
                  'requested' => 1,
                  'booked' => 1
                },
                7 => {
                  'rejected' => 1
                }
              }
            }
        }
      end

      context 'all prisons' do
        before do
          mars_visits_with_dates
          luna_visits_with_dates
        end

        it 'returns counts by state for all prisons that are grouped by year, and week' do
          expect(described_class.fetch_and_format(:concatenate)).to be ==
            { 'all' =>
              {
                2015 => {
                  53 => {
                    'cancelled' => 2
                  }
                },
                2016 => {
                  5 => {
                    'requested' => 2,
                    'rejected' => 2,
                    'booked' => 2
                  },
                  6 => {
                    'requested' => 2,
                    'booked' => 2
                  },
                  7 => {
                    'rejected' => 2
                  }
                }
              }
          }
        end
      end
    end

    describe Counters::CountVisitsByPrisonAndCalendarDate do
      before do
        luna_visits_with_dates
      end

      it 'returns counts by state that are grouped by prison, year, and week' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            {
              2016 => {
                1 => {
                  1 => {
                    'cancelled' => 1
                  }
                },
                2 => {
                  1 => {
                    'requested' => 1,
                    'booked' => 1,
                    'rejected' => 1
                  },
                  8 => {
                    'requested' => 1,
                    'booked' => 1
                  },
                  15 => {
                    'rejected' => 1
                  }
                }
              }
            }
        }
      end

      context 'all prisons' do
        before do
          luna_visits_with_dates
          mars_visits_with_dates
        end

        it 'counts visits and groups them by calendar date and state' do
          expect(described_class.fetch_and_format(:aggregate)).to be ==
            { 'all' =>
              {
                2016 => {
                  1 => {
                    1 => {
                      'cancelled' => 2
                    }
                  },
                  2 => {
                    1 => {
                      'requested' => 2,
                      'booked' => 2,
                      'rejected' => 2
                    },
                    8 => {
                      'requested' => 2,
                      'booked' => 2
                    },
                    15 => {
                      'rejected' => 2
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
