# frozen_string_literal: true
require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Timings do
  include_examples 'create visits with dates'

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

  describe Timings::TimelyAndOverdue do
    context 'that are not organized by date' do
      it 'counts all timely and overdue visits and group by prison' do
        expect(described_class.fetch_and_format).to be ==
                                                    { 'Lunar Penal Colony' =>
                                                      {
                                                        'timely' => {
                                                          'booked' => 1,
                                                          'rejected' => 1,
                                                          'cancelled' => 1,
                                                          'withdrawn' => 1
                                                        },
                                                        'overdue' => {
                                                          'booked' => 1,
                                                          'rejected' => 1,
                                                          'cancelled' => 1,
                                                          'withdrawn' => 1
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
                                                      } }
      end
    end

    context 'that are organized by date' do
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
                                                          } } },
                                                        'Martian Penal Colony' =>
                                                        { 2016 =>
                                                          { 5 => {
                                                            'overdue' => { 'booked' => 1, 'rejected' => 1 },
                                                            'timely' => { 'booked' => 1, 'rejected' => 1 }
                                                          } } } }
        end
      end
    end
  end
end
