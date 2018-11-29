require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Timings do
  before do
    book_a_luna_visit_late
    book_a_luna_visit_on_time
    cancel_a_luna_visit_late
    cancel_a_luna_visit_on_time
    withdraw_a_luna_visit_late
    withdraw_a_luna_visit_on_time
    reject_a_luna_visit_late
    reject_a_luna_visit_on_time
    book_a_mars_visit_late
    book_a_mars_visit_on_time
    reject_a_mars_visit_late
    reject_a_mars_visit_on_time
  end

  include_examples 'when creating visits with dates'

  describe Timings::TimelyAndOverdue do
    context 'when they are not organized by date' do
      it 'counts all overdue visits and group by prison' do
        expect(described_class.fetch_and_format).to be ==
          {
            'Lunar Penal Colony' => { 'overdue' => 4 },
            'Martian Penal Colony' => { 'overdue' => 2 }
          }
      end
    end

    context 'when they are organized by date' do
      describe Timings::TimelyAndOverdueByCalendarWeek do
        it 'counts visits and groups by prison, year, calendar week and visit state' do
          expect(described_class.fetch_and_format).to be ==
            { 'Lunar Penal Colony' =>
              { 2016 =>
                { 5 => {
                  'overdue' => {
                    'rejected' => 1,
                    'booked' => 1,
                    'cancelled' => 1,
                    'withdrawn' => 1
                  },
                  'timely' => {
                    'rejected' => 1,
                    'booked' => 1,
                    'cancelled' => 1,
                    'withdrawn' => 1
                  }
                }
                }
              },
              'Martian Penal Colony' =>
              { 2016 =>
                { 5 => {
                  'overdue' => { 'booked' => 1, 'rejected' => 1 },
                  'timely' => { 'booked' => 1, 'rejected' => 1 }
                }
                }
              }
          }
        end
      end
    end
  end
end
