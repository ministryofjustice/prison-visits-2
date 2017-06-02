require 'rails_helper'

RSpec.describe AvailableSlotEnumerator do
  subject {
    described_class.new(
      begin_on, end_on, recurring_slots, anomalous_slots, unbookable_dates
    )
  }

  let(:begin_on) { Date.new(2015, 10, 1) } # Thursday
  let(:end_on) { Date.new(2015, 10, 5) } # Monday
  let(:unbookable_dates) { [] }
  let(:anomalous_slots) { {} }

  context 'with no unbookable dates' do
    let(:recurring_slots) {
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

    it 'enumerates slots in five-day booking window' do
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
    let(:recurring_slots) {
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

  context 'with anomalous dates' do
    let(:recurring_slots) {
      {
        DayOfWeek::MON => [
          RecurringSlot.new(14, 0, 16, 10)
        ]
      }
    }
    let(:anomalous_slots) {
      {
        Date.new(2015, 10, 2) => [
          RecurringSlot.new(9, 30, 10, 30)
        ],
        Date.new(2015, 10, 5) => [
          RecurringSlot.new(11, 30, 12, 30)
        ]
      }
    }

    it 'overrides recurring slots with anomalous dates' do
      expect(subject.to_a).to eq(
        [
          ConcreteSlot.new(2015, 10, 2, 9, 30, 10, 30),
          ConcreteSlot.new(2015, 10, 5, 11, 30, 12, 30)
        ]
      )
    end
  end
end
