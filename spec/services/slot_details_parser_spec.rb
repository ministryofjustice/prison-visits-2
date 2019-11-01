require 'rails_helper'

RSpec.describe SlotDetailsParser do
  let(:parsed) { subject.parse(raw) }

  context 'when source is empty' do
    let(:raw) { {} }

    describe '#anomalous_slots' do
      it 'is empty' do
        expect(parsed.anomalous_slots).to be_empty
      end
    end
  end

  context 'when there are slot details' do
    let(:raw) {
      {
        'recurring' => {
          'mon' => ['1400-1610'],
          'tue' => %w[0900-1000 1400-1610]
        },
        'anomalous' => {
          '2014-12-24' => ['1400-1600'],
          '2014-12-31' => ['1400-1600']
        }
      }
    }

    describe 'anomalous_slots' do
      it 'lists slots for each anomalous date' do
        expect(parsed.anomalous_slots).to eq(
          Date.new(2014, 12, 24) => [
            RecurringSlot.new(14, 0, 16, 00)
          ],
          Date.new(2014, 12, 31) => [
            RecurringSlot.new(14, 0, 16, 00)
          ]
        )
      end
    end
  end
end
