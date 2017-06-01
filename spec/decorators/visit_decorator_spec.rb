require 'rails_helper'

RSpec.describe VisitDecorator do
  let(:visit) { create(:visit) }

  subject(:instance) { described_class.decorate(visit) }

  describe '#slots'do
    it 'are decorated object' do
      subject.slots.each do |slot|
        expect(slot).to be_decorated
      end
    end
  end

  describe '#processed_at' do
    subject(:processed_at) { instance.processed_at }

    context 'when requested' do
      let(:visit) { create(:visit, :requested) }

      it 'returns the visit creation time' do
        expect(processed_at).to eq(visit.created_at)
      end
    end

    context 'when not requested' do
      let!(:last_state_change) do
        VisitStateChange.create!(visit: visit,
                                 visit_state: 'cancelled',
                                 created_at: 1.day.from_now)
      end

      it 'returns the last visit state change creation time' do
        expect(processed_at).to eq(last_state_change.reload.created_at)
      end
    end
  end
end
