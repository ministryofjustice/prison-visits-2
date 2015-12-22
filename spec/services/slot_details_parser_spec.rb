require 'rails_helper'

RSpec.describe SlotDetailsParser do
  subject { described_class.new(raw) }

  context 'when source is empty' do
    let(:raw) { {} }

    describe 'recurring_slots' do
      it 'is empty' do
        expect(subject.recurring_slots).to be_empty
      end
    end

    describe 'unbookable_dates' do
      it 'is empty' do
        expect(subject.unbookable_dates).to be_empty
      end
    end
  end

  context 'when there are slot details' do
    let(:raw) {
      {
        'recurring' => {
          'mon' => ['1400-1610'],
          'tue' => ['0900-1000', '1400-1610']
        },
        'anomalous' => {
          '2014-12-24' => ['1400-1600'],
          '2014-12-31' => ['1400-1600']
        },
        'unbookable' => ['2014-12-25', '2014-12-26']
      }
    }

    describe 'recurring_slots' do
      it 'lists slots for each available day' do
        expect(subject.recurring_slots).to eq(
          DayOfWeek::MON => [
            RecurringSlot.new(14, 0, 16, 10)
          ],
          DayOfWeek::TUE => [
            RecurringSlot.new(9, 0, 10, 0),
            RecurringSlot.new(14, 0, 16, 10)
          ]
        )
      end
    end

    describe 'anomalous_slots' do
      it 'lists slots for each anomalous date' do
        expect(subject.anomalous_slots).to eq(
          Date.new(2014, 12, 24) => [
            RecurringSlot.new(14, 0, 16, 00)
          ],
          Date.new(2014, 12, 31) => [
            RecurringSlot.new(14, 0, 16, 00)
          ]
        )
      end
    end

    describe 'unbookable_dates' do
      it 'lists dates' do
        expect(subject.unbookable_dates).
          to eq([Date.new(2014, 12, 25), Date.new(2014, 12, 26)])
      end
    end
  end
end
