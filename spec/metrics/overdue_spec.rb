require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Overdue do
  before do
    book_a_luna_visit_late
    book_a_luna_visit_late
    book_a_luna_visit_on_time
    reject_a_luna_visit_late
    reject_a_luna_visit_on_time
    book_a_mars_visit_late
    book_a_mars_visit_on_time
    reject_a_mars_visit_late
    reject_a_mars_visit_on_time
    request_a_visit_that_remains_overdue
  end

  include_examples 'when creating visits with dates'

  context 'when they are not organised by date' do
    describe Overdue::CountOverdueVisits do
      it 'counts all overdue visits' do
        expect(described_class.fetch_and_format).to eq('booked' => 3,
                                                       'rejected' => 2,
                                                       'requested' => 1)
      end
    end

    describe Overdue::CountOverdueVisitsByPrison do
      it 'counts all overdue visits and group by prison' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            { 'booked' => 2,
              'rejected' => 1,
              'requested' => 1
            },
            'Martian Penal Colony' =>
            { 'booked' => 1,
              'rejected' => 1
            }
        }
      end
    end
  end

  context 'when they are organized by date' do
    describe Overdue::CountOverdueVisitsByPrisonAndCalendarWeek do
      it 'counts visits and groups by prison, year, calendar week and visit state' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            {
              2015 => {
                53 => {
                  'requested' => 1
                }
              },
              2016 => {
                5 => {
                  'rejected' => 1,
                  'booked' => 2
                }
              }
            },
            'Martian Penal Colony' =>
            {
              2016 => {
                5 => {
                  'rejected' => 1,
                  'booked' => 1
                }
              }
            }
        }
      end

      context 'when aggregated across all prisons' do
        it 'counts visits and groups by year, calendar week and visit state' do
          expect(described_class.fetch_and_format(:concatenate)).to be ==
            { 'all' =>
              {
                2015 => {
                  53 => {
                    'requested' => 1
                  }
                },
                2016 => {
                  5 => {
                    'rejected' => 2,
                    'booked' => 3
                  }
                }
              }
          }
        end
      end
    end

    describe Overdue::CountOverdueVisitsByPrisonAndCalendarDate do
      it 'counts visits and groups by prison, year, calendar week and visit state' do
        expect(described_class.fetch_and_format).to be ==
          { 'Lunar Penal Colony' =>
            {
              2016 => {
                1 => {
                  1 => {
                    'requested' => 1
                  }
                },
                2 => {
                  1 => {
                    'rejected' => 1,
                    'booked' => 2
                  }
                }
              }
            },
            'Martian Penal Colony' =>
            {
              2016 => {
                2 => {
                  1 => {
                    'rejected' => 1,
                    'booked' => 1
                  }
                }
              }
            }
        }
      end

      context 'when aggregated across all prisons' do
        it 'counts visits and groups by year, calendar week and visit state' do
          expect(described_class.fetch_and_format(:concatenate)).to be ==
            { 'all' =>
              {
                2016 => {
                  1 => {
                    1 => {
                      'requested' => 1
                    }
                  },
                  2 => {
                    1 => {
                      'rejected' => 2,
                      'booked' => 3
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
