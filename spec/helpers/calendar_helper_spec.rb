require 'rails_helper'

RSpec.describe CalendarHelper do
  describe 'weeks' do
    it 'enumerates whole weeks from tomorrow to cover month of booking window' do
      #
      #    Mo  Tu  We  Th  Fr  Sa  Su
      #    23  24  25  26  27a 28  29    First week
      #    30   1   2   3   4   5   6
      #     7   8   9  10  11  12  13
      #    14  15  16  17  18  19  20
      #    21  22  23  24  25  26b 27
      #    28  29  30  31c  1   2   3d   Last week
      #
      #    a = today; b = end of booking window;
      #    c = end of month concluding window; d = end of week
      #
      prison = build(:prison, lead_days: 3, booking_window: 28)
      Timecop.travel Date.new(2015, 11, 26) do # Thursday
        weeks = helper.weeks(prison)
        expect(weeks.length).to eq(6)
        expect(weeks.first.first).to eq(Date.new(2015, 11, 23))
        expect(weeks.last.last).to eq(Date.new(2016, 1, 3))
      end
    end
  end
end
