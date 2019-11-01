require "rails_helper"

RSpec.describe SlotInfoPresenter do
  let(:prison) { create :prison }

  subject { described_class.new(prison)  }

  describe '#slot_for' do
    context 'when there are not recurring slots on a given day' do
      let(:day) { 'wed' }

      it 'returns an empty list' do
        expect(subject.slots_for(day)).to eq([])
      end
    end

    context 'when there are recurring slots on a given day' do
      let(:day) { 'tue' }

      it 'shows the list' do
        expect(subject.slots_for(day)).to eq(%w[0900-1000 1400-1610])
      end
    end
  end
end
