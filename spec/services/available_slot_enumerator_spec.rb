RSpec.describe AvailableSlotEnumerator do
  subject {
    described_class.new(begin_date, regular_slots, unbookable_dates, 5)
  }
  let(:begin_date) { Date.new(2015, 10, 1) } # Thursday

  context 'with no unbookable dates' do
    let(:unbookable_dates) { [] }
    let(:regular_slots) {
      {
        DayOfWeek::MON => [
          RecurringSlot.new(14, 0, 16, 10)
        ],
        DayOfWeek::TUE => [
          RecurringSlot.new(9, 0, 10, 0),
          RecurringSlot.new(14, 0, 16, 10)
        ],
        DayOfWeek::FRI => [
          RecurringSlot.new(10, 0, 11, 30)
        ]
      }
    }

    it 'enumerates slots in five-day horizon' do
      expect(subject.to_a).to eq(
        [
          ConcreteSlot.new(2015, 10, 2, 10, 0, 11, 30),
          ConcreteSlot.new(2015, 10, 5, 14, 0, 16, 10)
        ]
      )
    end
  end

  context 'with unbookable dates' do
    let(:unbookable_dates) { [Date.new(2015, 10, 2)] }
    let(:regular_slots) {
      {
        DayOfWeek::MON => [
          RecurringSlot.new(14, 0, 16, 10)
        ],
        DayOfWeek::TUE => [
          RecurringSlot.new(9, 0, 10, 0),
          RecurringSlot.new(14, 0, 16, 10)
        ],
        DayOfWeek::FRI => [
          RecurringSlot.new(10, 0, 11, 30)
        ]
      }
    }

    it 'excludes unbookable dates when enumerating slots' do
      expect(subject.to_a).to eq(
        [ConcreteSlot.new(2015, 10, 5, 14, 0, 16, 10)]
      )
    end
  end
end
