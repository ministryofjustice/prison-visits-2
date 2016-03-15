require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Timings do
  include_examples 'create visits with dates'

  before do
    book_a_luna_visit_late
    book_a_luna_visit_on_time
    reject_a_luna_visit_late
    reject_a_luna_visit_on_time
    book_a_mars_visit_late
    book_a_mars_visit_on_time
    reject_a_mars_visit_late
    reject_a_mars_visit_on_time
  end

  describe Timings::TimelyAndOverdue do
    it 'counts all timely and overdue visits and group by prison' do
      expect(described_class.fetch_and_format).to be ==
        { 'Lunar Penal Colony' =>
          {
            'timely' => {
              'booked' => 1,
              'rejected' => 1
            },
            'overdue' => {
              'booked' => 1,
              'rejected' => 1
            }
          },
          'Martian Penal Colony' =>
          {
            'timely' => {
              'booked' => 1,
              'rejected' => 1
            },
            'overdue' => {
              'booked' => 1,
              'rejected' => 1
            }
          }
      }
    end
  end
end
